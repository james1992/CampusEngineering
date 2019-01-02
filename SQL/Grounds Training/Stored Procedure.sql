USE [FacilitiesMaintenance]
GO

DECLARE @MyCursor CURSOR;
DECLARE @FullName varchar(100);
DECLARE @Equipment varchar(100);
DECLARE @Type varchar(100);
DECLARE @Date date;

BEGIN
    SET @MyCursor = CURSOR FOR
    select top 100000 FullName, Equipment, TrainingType, TrainingDate from dbo.GroundsTraining
        where CopiedToMaster = 'No'      

    OPEN @MyCursor 
    FETCH NEXT FROM @MyCursor 
    INTO @FullName, @Equipment, @Type, @Date

    WHILE @@FETCH_STATUS = 0
    BEGIN
			UPDATE dbo.GroundsTrainingMaster SET
			GroundcrewClass = (CASE WHEN (@Equipment = 'Ground Crew' AND @Type = 'Class') THEN 'Yes' ELSE GroundcrewClass END),
			GroundcrewClassDate = (CASE WHEN (@Equipment = 'Ground Crew' AND @Type = 'Class') THEN @Date ELSE GroundcrewClassDate END),

			GroundcrewField = (CASE WHEN (@Equipment = 'Ground Crew' AND @Type = 'Field') THEN 'Yes' ELSE GroundcrewField END),
			GroundcrewFieldDate = (CASE WHEN (@Equipment = 'Ground Crew' AND @Type = 'Field') THEN @Date ELSE GroundcrewFieldDate END),

			StumpGrinderField = (CASE WHEN (@Equipment = 'Stump Grinder' AND @Type = 'Field') THEN 'Yes' ELSE StumpGrinderField END),
			StumpGrinderFieldDate = (CASE WHEN (@Equipment = 'Stump Grinder' AND @Type = 'Field') THEN @Date ELSE StumpGrinderFieldDate END),

			StumpGrinderManual = (CASE WHEN (@Equipment = 'Stump Grinder' AND @Type = 'Manual') THEN 'Yes' ELSE StumpGrinderManual END),
			StumpGrinderManualDate = (CASE WHEN (@Equipment = 'Stump Grinder' AND @Type = 'Manual') THEN @Date ELSE StumpGrinderManualDate END),

			ChainsawClass = (CASE WHEN (@Equipment = 'Chainsaw' AND @Type = 'Class') THEN 'Yes' ELSE ChainsawClass END),
			ChainsawClassDate = (CASE WHEN (@Equipment = 'Chainsaw' AND @Type = 'Class') THEN @Date ELSE ChainsawClassDate END),

			ChainsawManual = (CASE WHEN (@Equipment = 'Chainsaw' AND @Type = 'Manual') THEN 'Yes' ELSE ChainsawManual END),
			ChainsawManualDate = (CASE WHEN (@Equipment = 'Chainsaw' AND @Type = 'Manual') THEN @Date ELSE ChainsawManualDate END),

			ChainsawField = (CASE WHEN (@Equipment = 'Chainsaw' AND @Type = 'Field') THEN 'Yes' ELSE ChainsawField END),
			ChainsawFieldDate = (CASE WHEN (@Equipment = 'Chainsaw' AND @Type = 'Field') THEN @Date ELSE ChainsawFieldDate END),

			ChipperManual = (CASE WHEN (@Equipment = 'Chipper' AND @Type = 'Manual') THEN 'Yes' ELSE ChipperManual END),
			ChipperManualDate = (CASE WHEN (@Equipment = 'Chipper' AND @Type = 'Manual') THEN @Date ELSE ChipperManualDate END),

			ChipperField = (CASE WHEN (@Equipment = 'Chipper' AND @Type = 'Field') THEN 'Yes' ELSE ChipperField END),
			ChipperFieldDate = (CASE WHEN (@Equipment = 'Chipper' AND @Type = 'Field') THEN @Date ELSE ChipperFieldDate END),

			GenieManual = (CASE WHEN (@Equipment = 'Genie' AND @Type = 'Manual') THEN 'Yes' ELSE GenieManual END),
			GenieManualDate = (CASE WHEN (@Equipment = 'Genie' AND @Type = 'Manual') THEN @Date ELSE GenieManualDate END),

			JLGManual = (CASE WHEN (@Equipment = 'JLG' AND @Type = 'Manual') THEN 'Yes' ELSE JLGManual END),
			JLGManualDate = (CASE WHEN (@Equipment = 'JLG' AND @Type = 'Manual') THEN @Date ELSE JLGManualDate END),

			HiLiftField = (CASE WHEN (@Equipment = 'Hi Ranger' AND @Type = 'Field') THEN 'Yes' ELSE HiLiftField END),
			HiLiftFieldDate = (CASE WHEN (@Equipment = 'Hi Ranger' AND @Type = 'Field') THEN @Date ELSE HiLiftFieldDate END)

			WHERE dbo.GroundsTrainingMaster.FullName = @FullName

		FETCH NEXT FROM @MyCursor 
		INTO @FullName, @Equipment, @Type, @Date 
    END; 

    CLOSE @MyCursor ;
    DEALLOCATE @MyCursor;
END;
GO


UPDATE dbo.GroundsTraining SET
CopiedToMaster = 'Yes'
WHERE CopiedToMaster = 'No'
