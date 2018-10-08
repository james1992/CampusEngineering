-- =============================================
-- Author:      Jay Dahlstrom
-- Create date: 10/5/2018
-- Description: Stored Procedure that runs monthly
-- to calculate the current value of trees on campus.
-- Function is based on algorithm provided by Sara Shores.
-- =============================================

-- Figure out issue with values equally less than 1.



-- Set working database and truncate the tree value table to start from scratch
USE FacilitiesMaintenance
GO

TRUNCATE TABLE dbo.GroundsTreeValue
GO

-- Declare the variables pulled from each row in ViewGroundsTreeValueData
DECLARE @TreeNumber AS INT;
DECLARE @DSH AS FLOAT;
DECLARE @TreeType AS NCHAR(50);
DECLARE @SpeciesRating AS INT;
DECLARE @Condition AS INT;
DECLARE @Contribution INT;
DECLARE @Placement AS INT;

-- Declare placeholder variables for intermediate and final calculations and notations
DECLARE @AppraisedTrunkIncrease AS INT;
DECLARE @BasicTreeCost AS INT;
DECLARE @AssessedValue AS INT;
DECLARE @FinalAssessedValue AS INT;
DECLARE @ValueNotes AS NCHAR(50)

-- Declare and instantiate the cursor
DECLARE @TreeValueCursor AS CURSOR;

SET @TreeValueCursor = CURSOR FOR
SELECT TreeNumber, DSH, TreeType, SpeciesRating, ConditionNumber, Contribution, Placement
FROM ViewGroundsTreeValueData

OPEN @TreeValueCursor

FETCH NEXT FROM @TreeValueCursor INTO @TreeNumber, @DSH, @TreeType, @SpeciesRating, @Condition, @Contribution, @Placement;

WHILE @@FETCH_STATUS = 0
BEGIN

	-- Handle NULL Values that would cause the calculations to fail. If a row contains a NULL value update the notes and skip the calculations
	IF @DSH IS NULL OR @TreeType IS NULL OR /* @SpeciesRating IS NULL OR */ @Condition IS NULL OR @Contribution IS NULL OR @Placement IS NULL
		SET @ValueNotes = 'More Information Required for Value'
	ELSE

		-- If the DSH is over 30" run one appraised trunk increase calculation and round to nearest int.  If under 30" run a different appraisal
		IF @DSH > 30
			SET @AppraisedTrunkIncrease = ROUND(((((@DSH * @DSH) * -.335) + (@DSH * 69.3) - 1087) - 7),0)
		ELSE
			SET @AppraisedTrunkIncrease = ROUND((((@DSH * @DSH) * .785) - 7),0)
		
		-- Calculate basic tree cost.  Cost is different depending on tree type
		IF @TreeType = 'Broadleaf Evergreen' OR @TreeType = 'Deciduous' OR @TreeType = 'Evergreen' OR @TreeType = 'Palm'
			SET @BasicTreeCost = (@AppraisedTrunkIncrease * 72) + 480
		ELSE
			SET @BasicTreeCost = (@AppraisedTrunkIncrease * 57) + 380

		-- Set the assessed value by multiplying basic tree cost by tree and species specific values.  Round to nearest int  
		SET @AssessedValue = ROUND((@BasicTreeCost * /* (@SpeciesRating * .01) * */ (@Condition*.01) * (((85 + @Contribution + @Placement)/3)* .01)), 0) -- the 85 is for standard site rating

		-- If the Assessed Value is less than $5000 round to nearest 10 otherwise round to nearest 100
		IF @AssessedValue < 5000
			SET @FinalAssessedValue = ROUND(@AssessedValue, -1)
		ELSE
			SET @FinalAssessedValue = ROUND(@AssessedValue, -2)
	
	-- Insert the Final Assessed Values into GroundsTreeValue table.  This table is accessed by the Public Trees Map (after migration to Public database via Python script)
	INSERT INTO dbo.GroundsTreeValue (TreeNumber, TreeValue, Notes)
	VALUES (@TreeNumber, @FinalAssessedValue, @ValueNotes)

	-- Console Log the insert values for error checking if needed
	
	PRINT cast(@TreeNumber AS NCHAR(50)) 
	PRINT cast(@FinalAssessedValue AS NCHAR(50))
	PRINT cast(@AssessedValue AS NCHAR(50))
	PRINT cast(@BasicTreeCost AS NCHAR(50))
	PRINT @ValueNotes
	
	FETCH NEXT FROM @TreeValueCursor INTO @TreeNumber, @DSH, @TreeType, @SpeciesRating, @Condition, @Contribution, @Placement;
END

-- End the cursor
CLOSE @TreeValueCursor
DEALLOCATE @TreeValueCursor