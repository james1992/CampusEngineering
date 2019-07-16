USE [msdb]
GO

/****** Object:  Job [SQL - 60 minutes - Updates]    Script Date: 7/11/2019 2:22:37 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 7/11/2019 2:22:37 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SQL - 60 minutes - Updates', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'In order to improve web map performance stored procedures were implemented to replace spatial views.  Every hour between 7 am and 5 pm this job runs each store procedure to update GIS web maps for clients. Each project is its own step in the job.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'fsgis', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Fire Extinguishers]    Script Date: 7/11/2019 2:22:37 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Fire Extinguishers', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- When a new barcode is applied to an extinguisher convert all previous inspection records from old barcode to new one.

UPDATE FireExtinguishersInspections
SET LocationBarCode = new.NewLocationBarcode
FROM FireExtinguishersBarcodeUpdates as new
WHERE FireExtinguishersInspections.LocationBarCode = new.OldLocationBarcode AND new.Processed = ''No''
GO

UPDATE FireExtinguishersBarcodeUpdates
SET Processed = ''Yes''
WHERE Processed = ''No''
GO

-- Update Fire Extinguisher Progress Table which controlls web map building colors

TRUNCATE TABLE FireExtinguishersBuildingInspectionsProgress
GO

INSERT INTO FireExtinguishersBuildingInspectionsProgress
SELECT *
FROM ViewFireExtinguisherBuildingInspectionProgress
GO', 
		@database_name=N'CampusEngineeringOperations', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Grounds Master Training List Updates]    Script Date: 7/11/2019 2:22:37 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Grounds Master Training List Updates', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @MyCursor CURSOR;
DECLARE @FullName varchar(100);
DECLARE @Equipment varchar(100);
DECLARE @Type varchar(100);
DECLARE @Date date;

BEGIN
    SET @MyCursor = CURSOR FOR
    select top 100000 FullName, Equipment, TrainingType, TrainingDate from dbo.GroundsTraining
        where CopiedToMaster = ''No''      

    OPEN @MyCursor 
    FETCH NEXT FROM @MyCursor 
    INTO @FullName, @Equipment, @Type, @Date

    WHILE @@FETCH_STATUS = 0
    BEGIN
			UPDATE dbo.GroundsTrainingMaster SET
			GroundcrewClass = (CASE WHEN (@Equipment = ''Ground Crew'' AND @Type = ''Class'') THEN ''Yes'' ELSE GroundcrewClass END),
			GroundcrewClassDate = (CASE WHEN (@Equipment = ''Ground Crew'' AND @Type = ''Class'') THEN @Date ELSE GroundcrewClassDate END),

			GroundcrewField = (CASE WHEN (@Equipment = ''Ground Crew'' AND @Type = ''Field'') THEN ''Yes'' ELSE GroundcrewField END),
			GroundcrewFieldDate = (CASE WHEN (@Equipment = ''Ground Crew'' AND @Type = ''Field'') THEN @Date ELSE GroundcrewFieldDate END),

			StumpGrinderField = (CASE WHEN (@Equipment = ''Stump Grinder'' AND @Type = ''Field'') THEN ''Yes'' ELSE StumpGrinderField END),
			StumpGrinderFieldDate = (CASE WHEN (@Equipment = ''Stump Grinder'' AND @Type = ''Field'') THEN @Date ELSE StumpGrinderFieldDate END),

			StumpGrinderManual = (CASE WHEN (@Equipment = ''Stump Grinder'' AND @Type = ''Manual'') THEN ''Yes'' ELSE StumpGrinderManual END),
			StumpGrinderManualDate = (CASE WHEN (@Equipment = ''Stump Grinder'' AND @Type = ''Manual'') THEN @Date ELSE StumpGrinderManualDate END),

			ChainsawClass = (CASE WHEN (@Equipment = ''Chainsaw'' AND @Type = ''Class'') THEN ''Yes'' ELSE ChainsawClass END),
			ChainsawClassDate = (CASE WHEN (@Equipment = ''Chainsaw'' AND @Type = ''Class'') THEN @Date ELSE ChainsawClassDate END),

			ChainsawManual = (CASE WHEN (@Equipment = ''Chainsaw'' AND @Type = ''Manual'') THEN ''Yes'' ELSE ChainsawManual END),
			ChainsawManualDate = (CASE WHEN (@Equipment = ''Chainsaw'' AND @Type = ''Manual'') THEN @Date ELSE ChainsawManualDate END),

			ChainsawField = (CASE WHEN (@Equipment = ''Chainsaw'' AND @Type = ''Field'') THEN ''Yes'' ELSE ChainsawField END),
			ChainsawFieldDate = (CASE WHEN (@Equipment = ''Chainsaw'' AND @Type = ''Field'') THEN @Date ELSE ChainsawFieldDate END),

			ChipperManual = (CASE WHEN (@Equipment = ''Chipper'' AND @Type = ''Manual'') THEN ''Yes'' ELSE ChipperManual END),
			ChipperManualDate = (CASE WHEN (@Equipment = ''Chipper'' AND @Type = ''Manual'') THEN @Date ELSE ChipperManualDate END),

			ChipperField = (CASE WHEN (@Equipment = ''Chipper'' AND @Type = ''Field'') THEN ''Yes'' ELSE ChipperField END),
			ChipperFieldDate = (CASE WHEN (@Equipment = ''Chipper'' AND @Type = ''Field'') THEN @Date ELSE ChipperFieldDate END),

			GenieManual = (CASE WHEN (@Equipment = ''Genie'' AND @Type = ''Manual'') THEN ''Yes'' ELSE GenieManual END),
			GenieManualDate = (CASE WHEN (@Equipment = ''Genie'' AND @Type = ''Manual'') THEN @Date ELSE GenieManualDate END),

			JLGManual = (CASE WHEN (@Equipment = ''JLG'' AND @Type = ''Manual'') THEN ''Yes'' ELSE JLGManual END),
			JLGManualDate = (CASE WHEN (@Equipment = ''JLG'' AND @Type = ''Manual'') THEN @Date ELSE JLGManualDate END),

			HiLiftField = (CASE WHEN (@Equipment = ''Hi Ranger'' AND @Type = ''Field'') THEN ''Yes'' ELSE HiLiftField END),
			HiLiftFieldDate = (CASE WHEN (@Equipment = ''Hi Ranger'' AND @Type = ''Field'') THEN @Date ELSE HiLiftFieldDate END)

			WHERE dbo.GroundsTrainingMaster.FullName = @FullName

		FETCH NEXT FROM @MyCursor 
		INTO @FullName, @Equipment, @Type, @Date 
    END; 

    CLOSE @MyCursor ;
    DEALLOCATE @MyCursor;
END;
GO


UPDATE dbo.GroundsTraining SET
CopiedToMaster = ''Yes''
WHERE CopiedToMaster = ''No''', 
		@database_name=N'FacilitiesMaintenance', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Confidence Test Maintenance Updates]    Script Date: 7/11/2019 2:22:37 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Confidence Test Maintenance Updates', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- =============================================
-- Author:		Jay Dahlstrom
-- Create date: 1/28/2019
-- Description:	This TSQL is designed to be run through
-- SQL Server agent on an hourly basis to update the
-- Confidence Test Maintenance tables.  This replaces
-- all of the views that previously supported the web maps
-- with only the two tables produced by this script.
-- =============================================

-- Define the working database

USE CampusEngineeringOperations

-- Create a temporary table to hold confidence test maintenance most recent data
-- Table is automatically purged from tempdb after session, drop statement is there just in case to prevent errors.

IF OBJECT_ID(''tempdb.dbo.#ConfidenceTestMaintenanceMostRecent'') IS NOT NULL
	DROP TABLE #ConfidenceTestMaintenanceMostRecent

CREATE TABLE #ConfidenceTestMaintenanceMostRecent 
		(OBJECTID INT NOT NULL, 
		 REL_GlobalID uniqueidentifier NULL,
		 InspectionDate datetime2(7) NULL,
		 Notes nvarchar(250) NULL,
		 UserID nvarchar(50) NULL,
		 last_edited_date datetime2(7) NULL)
GO

-- Insert most recent maintenance data into temp table above

INSERT INTO #ConfidenceTestMaintenanceMostRecent
SELECT	OBJECTID, 
		REL_GlobalID, 
		InspectionDate, 
		Notes, 
		UserID, 
		last_edited_date
FROM    dbo.CONFIDENCETESTSMAINTENANCE
-- The purpose of the where statement is to return only the most recent inspection for each asset
WHERE   (OBJECTID IN (SELECT MAX(OBJECTID) AS OID FROM dbo.CONFIDENCETESTSMAINTENANCE AS ResultsMax GROUP BY REL_GlobalID))
GO

-- Truncate ConfidenceTestMaintenanceProgress table and then populate with new values
-- These are the points on the map.

TRUNCATE TABLE ConfidenceTestsMaintenanceProgress
GO

INSERT INTO dbo.ConfidenceTestsMaintenanceProgress

SELECT      OBJECTID, 
			System, 
			TestStatus,
			CASE WHEN TestStatus = ''5 Year Maintenance Complete'' THEN 1 ELSE 0 END AS TestCompleteCount, 
			CurrentMonth, 
			FacilityNumber, 
			FacilityName, 
			SystemLocation, 
			Serves, 
			MaintenanceReportYear, 
			DocumentStorage, 
			SystemDescription, 
			InspectionDate, 
			Notes, 
			UserID, 
			last_edited_date, 
			SHAPE 

FROM        (SELECT dbo.CONFIDENCETESTS.OBJECTID, 
					dbo.CONFIDENCETESTS.System, 
					CASE WHEN MaintenanceReportYear = YEAR(InspectionDate) THEN ''5 Year Maintenance Complete'' 
					WHEN MaintenanceReportYear > YEAR(InspectionDate) AND YEAR(InspectionDate) >= (MaintenanceReportYear - 5) THEN ''5 Year Maintenance Complete'' 
					-- Determine if the last test date is in compliance or not.  Different reporting month for standpipes and sprinklers
					WHEN (System = ''Wet Standpipe'' OR System = ''Dry Standpipe'') AND MaintenanceReportYear = YEAR(GETDATE()) AND YEAR(InspectionDate) >= (MaintenanceReportYear - 5) AND MONTH(GETDATE()) < 8 THEN ''5 Year Maintenance Complete'' 
					WHEN (System = ''Wet Standpipe'' OR System = ''Dry Standpipe'') AND MaintenanceReportYear = YEAR(GETDATE()) AND YEAR(InspectionDate) >= (MaintenanceReportYear - 5) AND MONTH(GETDATE()) = 8 THEN ''5 Year Maintenance Due'' 
					WHEN (System = ''Wet Standpipe'' OR System = ''Dry Standpipe'') AND MaintenanceReportYear = YEAR(GETDATE()) AND YEAR(InspectionDate) >= (MaintenanceReportYear - 5) AND MONTH(GETDATE()) > 8 THEN ''5 Year Maintenance Past Due'' 
					WHEN (System = ''Wet Sprinkler'' OR System = ''Dry Sprinkler'') AND MaintenanceReportYear = YEAR(GETDATE()) AND YEAR(InspectionDate) >= (MaintenanceReportYear - 5) AND MONTH(GETDATE()) < 7 THEN ''5 Year Maintenance Complete'' 
					WHEN (System = ''Wet Sprinkler'' OR System = ''Dry Sprinkler'') AND MaintenanceReportYear = YEAR(GETDATE()) AND YEAR(InspectionDate) >= (MaintenanceReportYear - 5) AND MONTH(GETDATE()) = 7 THEN ''5 Year Maintenance Due'' 
					WHEN (System = ''Wet Sprinkler'' OR System = ''Dry Sprinkler'') AND MaintenanceReportYear = YEAR(GETDATE()) AND YEAR(InspectionDate) >= (MaintenanceReportYear - 5) AND MONTH(GETDATE()) > 7 THEN ''5 Year Maintenance Past Due'' 
					WHEN YEAR(InspectionDate) < (MaintenanceReportYear - 5) THEN ''5 Year Maintenance Past Due'' 
					WHEN InspectionDate IS NULL AND YEAR(GETDATE()) < MaintenanceReportYear THEN ''Test not Due Yet''
					WHEN InspectionDate IS NULL AND YEAR(GETDATE()) = MaintenanceReportYear THEN ''5 Year Maintenance Due''
					WHEN InspectionDate IS NULL THEN ''No Previously Maintenance Records'' END AS TestStatus,
					 
					MONTH(GETDATE()) AS CurrentMonth, 
					dbo.CONFIDENCETESTS.FacNum AS FacilityNumber, 
					dbo.CONFIDENCETESTS.FacName AS FacilityName, 
					dbo.CONFIDENCETESTS.Location AS SystemLocation, 
					dbo.CONFIDENCETESTS.Serves, 
					dbo.CONFIDENCETESTS.Documents AS DocumentStorage, 
					dbo.CONFIDENCETESTS.SystemDescription, 
					dbo.CONFIDENCETESTS.MaintenanceReportYear, 
					#ConfidenceTestMaintenanceMostRecent.InspectionDate, 
					#ConfidenceTestMaintenanceMostRecent.Notes, 
					#ConfidenceTestMaintenanceMostRecent.UserID, 
					#ConfidenceTestMaintenanceMostRecent.last_edited_date, 
					dbo.CONFIDENCETESTS.SHAPE
					FROM dbo.CONFIDENCETESTS LEFT OUTER JOIN
						 #ConfidenceTestMaintenanceMostRecent ON dbo.CONFIDENCETESTS.GlobalID = #ConfidenceTestMaintenanceMostRecent.REL_GlobalID
					-- Filter out everything except for active standpipes and sprinklers
					WHERE (dbo.CONFIDENCETESTS.FeatureStatus = N''Active'') AND 
					(dbo.CONFIDENCETESTS.MaintenanceReportYear IS NOT NULL) AND (dbo.CONFIDENCETESTS.System = ''Dry Sprinkler'' OR dbo.CONFIDENCETESTS.System = ''Dry Standpipe'' OR dbo.CONFIDENCETESTS.System = ''Wet Sprinkler'' OR dbo.CONFIDENCETESTS.System = ''Wet Standpipe'')) AS innertable
GO

-- Create a temporary table to hold confidence test maintenance building progress aggregate data
-- Table is automatically purged after session, drop statement is there just in case to prevent errors.

IF OBJECT_ID(''tempdb.dbo.#ConfidenceTestMaintenanceBuildingProgress'') IS NOT NULL
	DROP TABLE #ConfidenceTestMaintenanceBuildingProgress

CREATE TABLE #ConfidenceTestMaintenanceBuildingProgress 
		(FacilityNumber nvarchar(5) NULL, 
		 DocumentStorage nvarchar(500) NULL,
		 NumberComplete int NULL,
		 TotalTestsToDate int NULL,
		 last_edited_date datetime2(7) NULL)
GO

-- Insert building inspection progress data into temp table above

INSERT INTO #ConfidenceTestMaintenanceBuildingProgress
SELECT      FacilityNumber, 
			DocumentStorage, 
			SUM(TestCompleteCount) AS NumberComplete, 
			COUNT(TestStatus) AS TotalTestsToDate, 
			MIN(last_edited_date) AS LastEdited
FROM        dbo.ConfidenceTestsMaintenanceProgress
WHERE TestStatus <> ''Test not Due Yet''
GROUP BY FacilityNumber, DocumentStorage
GO

-- Truncate ConfidenceTestMaintenanceBuildingProgress table and then populate with new values
-- There are the buildings on the map.

TRUNCATE TABLE ConfidenceTestsMaintenanceBuildingProgress
GO

INSERT INTO dbo.ConfidenceTestsMaintenanceBuildingProgress

SELECT	dbo.ViewUniversityBuildings.FacilityNumber, 
		dbo.ViewUniversityBuildings.FacilityName, 
		#ConfidenceTestMaintenanceBuildingProgress.DocumentStorage, 
		#ConfidenceTestMaintenanceBuildingProgress.NumberComplete, 
		#ConfidenceTestMaintenanceBuildingProgress.TotalTestsToDate, 
		#ConfidenceTestMaintenanceBuildingProgress.NumberComplete / CAST(#ConfidenceTestMaintenanceBuildingProgress.TotalTestsToDate AS FLOAT) AS PercentComplete, 
		#ConfidenceTestMaintenanceBuildingProgress.last_edited_date,
		dbo.ViewUniversityBuildings.SHAPE 

FROM dbo.ViewUniversityBuildings INNER JOIN
         #ConfidenceTestMaintenanceBuildingProgress ON dbo.ViewUniversityBuildings.FacilityNumber = #ConfidenceTestMaintenanceBuildingProgress.FacilityNumber', 
		@database_name=N'CampusEngineeringOperations', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Confidence Test Annual Updates]    Script Date: 7/11/2019 2:22:37 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Confidence Test Annual Updates', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- =============================================
-- Author:		Jay Dahlstrom
-- Create date: 1/28/2019
-- Description:	This TSQL is designed to be run through
-- SQL Server agent on an hourly basis to update the
-- Confidence Test Annual tables.  This replaces
-- all of the views that previously supported the web maps
-- with only the two tables produced by this script.
-- =============================================

-- Define the working database

USE CampusEngineeringOperations

-- Create a temporary table to hold confidence test most recent data
-- Table is automatically purged after session, drop statement is there just in case to prevent errors.

IF OBJECT_ID(''tempdb.dbo.#ConfidenceTestMostRecent'') IS NOT NULL
	DROP TABLE #ConfidenceTestMostRecent

CREATE TABLE #ConfidenceTestMostRecent 
		(OBJECTID INT NOT NULL, 
		 REL_GlobalID uniqueidentifier NULL,
		 InspectionResult nvarchar(50) NULL,
		 InspectionDate datetime2(7) NULL,
		 Notes nvarchar(250) NULL,
		 UserID nvarchar(50) NULL,
		 last_edited_date datetime2(7) NULL)
GO

-- Insert most recent inspection data into temp table above

INSERT INTO #ConfidenceTestMostRecent
SELECT	OBJECTID, 
		REL_GlobalID, 
		Result,
		InspectionDate, 
		Notes, 
		UserID, 
		last_edited_date
FROM    dbo.CONFIDENCETESTSINSPECTIONS
-- The purpose of the where statement is to return only the most recent inspection for each asset
WHERE   (OBJECTID IN (SELECT MAX(OBJECTID) AS OID FROM dbo.CONFIDENCETESTSINSPECTIONS AS ResultsMax GROUP BY REL_GlobalID))
GO

-- Truncate ConfidenceTestProgress table and then populate with new values
-- These are the points on the map.

TRUNCATE TABLE ConfidenceTestsProgress
GO

INSERT INTO ConfidenceTestsProgress

SELECT OBJECTID, 
System, 
TestStatus, 
CASE WHEN TestStatus = ''Confidence Test Complete'' THEN 1 ELSE 0 END AS TestCompleteCount,
CurrentMonth, 
FacilityNumber, 
FacilityName, 
SystemLocation, 
Serves, 
MonthDue, 
DocumentStorage, 
SystemDescription,  
InspectionDate, 
QuarterInspected,
Notes, 
UserID, 
last_edited_date,
SHAPE 

FROM  (SELECT	dbo.CONFIDENCETESTS.OBJECTID, 
				dbo.CONFIDENCETESTS.System, 
				-- Determine if the most recent inspection date is in compliance or not.
				CASE WHEN InspectionResult = ''Yellow (Maintenance Required)'' THEN ''Maintenance Required'' 
				WHEN InspectionResult = ''Red (System Not Operational)'' THEN ''Maintenance Required'' 
				WHEN YEAR(GETDATE()) - YEAR(InspectionDate) = 0 THEN ''Confidence Test Complete'' 
				WHEN MONTH(GETDATE()) = MonthDue THEN ''Confidence Test Due'' 
				WHEN MONTH(GETDATE()) > MonthDue AND YEAR(GETDATE()) - YEAR(InspectionDate) = 1 THEN ''Confidence Past Due'' 
				WHEN MONTH(GETDATE()) < MonthDue AND YEAR(GETDATE()) - YEAR(InspectionDate) = 1 THEN ''Confidence Test Complete'' 
				WHEN YEAR(GETDATE()) - YEAR(InspectionDate) > 1 THEN ''Confidence Past Due'' 
				WHEN InspectionDate IS NULL THEN ''No Previously Recorded Tests'' END AS TestStatus, 

				MONTH(GETDATE()) AS CurrentMonth, 
				dbo.CONFIDENCETESTS.FacNum AS FacilityNumber, 
				dbo.CONFIDENCETESTS.FacName AS FacilityName, 
				dbo.CONFIDENCETESTS.Location AS SystemLocation, 
				dbo.CONFIDENCETESTS.Serves, 
				dbo.CONFIDENCETESTS.MonthDue, 
				dbo.CONFIDENCETESTS.Documents AS DocumentStorage, 
				dbo.CONFIDENCETESTS.SystemDescription, 
				dbo.CONFIDENCETESTS.Quarter AS QuarterInspected, 
				#ConfidenceTestMostRecent.InspectionDate, 
				#ConfidenceTestMostRecent.Notes, 
				#ConfidenceTestMostRecent.UserID, 
				#ConfidenceTestMostRecent.last_edited_date, 
				dbo.CONFIDENCETESTS.SHAPE
				FROM dbo.CONFIDENCETESTS LEFT OUTER JOIN
					 #ConfidenceTestMostRecent ON dbo.CONFIDENCETESTS.GlobalID = #ConfidenceTestMostRecent.REL_GlobalID
				-- Filter out inactive points and all standpipes.
				WHERE (dbo.CONFIDENCETESTS.FeatureStatus = N''Active'') AND (dbo.CONFIDENCETESTS.System <> N''Wet Standpipe'') AND (dbo.CONFIDENCETESTS.System <> N''Dry Standpipe'')) AS innerTable

-- Create a temporary table to hold confidence test annual building progress aggregate data
-- Table is automatically purged after session, drop statement is there just in case to prevent errors.

IF OBJECT_ID(''tempdb.dbo.#ConfidenceTestBuildingProgress'') IS NOT NULL
	DROP TABLE #ConfidenceTestBuildingProgress

CREATE TABLE #ConfidenceTestBuildingProgress 
		(FacilityNumber nvarchar(5) NULL, 
		 DocumentStorage nvarchar(500) NULL,
		 NumberComplete int NULL,
		 TotalTestsToDate int NULL,
		 last_edited_date datetime2(7) NULL)
GO

-- Insert building inspection progress data into temp table above

INSERT INTO #ConfidenceTestBuildingProgress
SELECT      FacilityNumber, 
			DocumentStorage, 
			SUM(TestCompleteCount) AS NumberComplete, 
			COUNT(OBJECTID) AS TotalTestsToDate, 
			MIN(last_edited_date) AS LastEdited
FROM        dbo.ConfidenceTestsProgress
GROUP BY FacilityNumber, DocumentStorage
GO

-- Truncate ConfidenceTestBuildingProgress table and then populate with new values
-- These are the buildings on the map.

TRUNCATE TABLE ConfidenceTestsBuildingProgress
GO

INSERT INTO dbo.ConfidenceTestsBuildingProgress

SELECT	dbo.ViewUniversityBuildings.FacilityNumber, 
		dbo.ViewUniversityBuildings.FacilityName, 
		#ConfidenceTestBuildingProgress.DocumentStorage, 
		#ConfidenceTestBuildingProgress.NumberComplete, 
		#ConfidenceTestBuildingProgress.TotalTestsToDate, 
		#ConfidenceTestBuildingProgress.NumberComplete / CAST(#ConfidenceTestBuildingProgress.TotalTestsToDate AS FLOAT) AS PercentComplete, 
		#ConfidenceTestBuildingProgress.last_edited_date,
		dbo.ViewUniversityBuildings.SHAPE 

FROM dbo.ViewUniversityBuildings INNER JOIN
         #ConfidenceTestBuildingProgress ON dbo.ViewUniversityBuildings.FacilityNumber = #ConfidenceTestBuildingProgress.FacilityNumber', 
		@database_name=N'CampusEngineeringOperations', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Water Treatment Condenser Water Report]    Script Date: 7/11/2019 2:22:37 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Water Treatment Condenser Water Report', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- =============================================
-- Author:		Jay Dahlstrom
-- Create date: 2/22/2019
-- Description:	This TSQL is designed to be run through
-- SQL Server agent on an hourly basis to update the
-- Water Treatment Condenser Water Report table.  
-- This tables contains the properly formatted information
-- for the monthly inspection reports email that is
-- produced by MS Flow.
-- =============================================

-- Define the working database

USE FacilitiesMaintenance

-- Remove all of the old records in preparation for data load

TRUNCATE TABLE WaterTreatmentCondenserWaterReport
GO

INSERT INTO dbo.WaterTreatmentCondenserWaterReport

SELECT      BuildingSystem, 
			AvgConductivity, 
			AvgTRASAR,
			AvgpH, 
			AvgFreeChlorine, 
			AvgTotalBacteria, 
			AvgTemperature, 
			AvgORP, 
			YearAndMonth 
FROM  (SELECT        
			CONCAT(BaseComponents.dbo.ViewUniversityBuildings.FacilityName, ''-'', dbo.WaterTreatmentCondenserWaterTests.LoopType) AS BuildingSystem, 
			AVG(dbo.WaterTreatmentCondenserWaterTests.Conductivity) AS AvgConductivity, 
			CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.TRASAR), 2, 1) AS decimal(18, 2)) AS AvgTRASAR, 
			CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.pH), 2, 1) AS decimal(18, 2)) AS AvgpH, 
			CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.FreeChlorine), 2, 1) AS decimal(18, 2)) AS AvgFreeChlorine, 
			CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.TotalBacteria), 2, 1) AS decimal(18, 2)) AS AvgTotalBacteria, 
			CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.Tempurature), 2, 1) AS decimal(18, 2)) AS AvgTemperature, 
            CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.ORP), 2, 1) AS decimal(18, 2)) AS AvgORP, 
			CONCAT(YEAR(dbo.WaterTreatmentCondenserWaterTests.SurveyDate), ''-'', FORMAT(dbo.WaterTreatmentCondenserWaterTests.SurveyDate, ''MM'')) AS YearAndMonth
FROM        dbo.WaterTreatmentCondenserWaterTests LEFT OUTER JOIN
				BaseComponents.dbo.ViewUniversityBuildings ON dbo.WaterTreatmentCondenserWaterTests.FacNum = BaseComponents.dbo.ViewUniversityBuildings.FacilityNumber
WHERE		(BaseComponents.dbo.ViewUniversityBuildings.FacilityName IS NOT NULL)
GROUP BY	CONCAT(BaseComponents.dbo.ViewUniversityBuildings.FacilityName, ''-'', dbo.WaterTreatmentCondenserWaterTests.LoopType), 
			CONCAT(YEAR(dbo.WaterTreatmentCondenserWaterTests.SurveyDate), ''-'', FORMAT(dbo.WaterTreatmentCondenserWaterTests.SurveyDate, ''MM''))) AS innertable
GO', 
		@database_name=N'FacilitiesMaintenance', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Water Treatment Closed Loop Report]    Script Date: 7/11/2019 2:22:37 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Water Treatment Closed Loop Report', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- =============================================
-- Author:		Jay Dahlstrom
-- Create date: 6/11/2019
-- Description:	This TSQL is designed to be run through
-- SQL Server agent on an hourly basis to update the
-- Water Treatment Closed Loops Water Report table.  
-- This tables contains the properly formatted information
-- for the PowerBI reports.
-- =============================================

-- Define the working database

USE FacilitiesMaintenance

-- Remove all of the old records in preparation for data load

TRUNCATE TABLE WaterTreatmentClosedLoopsWaterReport
GO

INSERT INTO dbo.WaterTreatmentClosedLoopsWaterReport

SELECT	BuildingSystem, 
		AvgConductivity, 
		AvgpH, 
		AvgAzole, 
		AvgTotalBacteria, 
		AvgCopper, 
		AvgIron, 
		AvgMakeupMeter, 
		AvgMildCopperCorrosionRate, 
		AvgMildSteelCorrosionRate, 
		YearAndMonth
FROM (SELECT CONCAT(BaseComponents.dbo.ViewUniversityBuildings.FacilityName, ''-'', dbo.WaterTreatmentClosedLoopsWaterTests.LoopType) AS BuildingSystem, 
             AVG(dbo.WaterTreatmentClosedLoopsWaterTests.Conductivity) AS AvgConductivity, 
			 CAST(ROUND(AVG(dbo.WaterTreatmentClosedLoopsWaterTests.pH), 2, 1) AS decimal(18, 2)) AS AvgpH, 
             CAST(ROUND(AVG(dbo.WaterTreatmentClosedLoopsWaterTests.Azole), 2, 1) AS decimal(18, 2)) AS AvgAzole, 
			 CAST(ROUND(AVG(dbo.WaterTreatmentClosedLoopsWaterTests.TotalBacteria), 2, 1) AS decimal(18, 2)) AS AvgTotalBacteria, 
			 CAST(ROUND(AVG(dbo.WaterTreatmentClosedLoopsWaterTests.Copper), 2, 1) AS decimal(18, 2)) AS AvgCopper, 
			 CAST(ROUND(AVG(dbo.WaterTreatmentClosedLoopsWaterTests.Iron), 2, 1) AS decimal(18, 2)) AS AvgIron, 
			 CAST(ROUND(AVG(dbo.WaterTreatmentClosedLoopsWaterTests.MakeupMeter), 2, 1) AS decimal(18, 2)) AS AvgMakeupMeter, 
             CAST(ROUND(AVG(dbo.WaterTreatmentClosedLoopsWaterTests.MildCopperCorrosionRate), 2, 1) AS decimal(18, 2)) AS AvgMildCopperCorrosionRate, 
             CAST(ROUND(AVG(dbo.WaterTreatmentClosedLoopsWaterTests.MildSteelCorrosionRate), 2, 1) AS decimal(18, 2)) AS AvgMildSteelCorrosionRate, 
             CONCAT(YEAR(dbo.WaterTreatmentClosedLoopsWaterTests.SurveyDate), ''-'', FORMAT(dbo.WaterTreatmentClosedLoopsWaterTests.SurveyDate, ''MM'')) AS YearAndMonth
             FROM dbo.WaterTreatmentClosedLoopsWaterTests LEFT OUTER JOIN
                      BaseComponents.dbo.ViewUniversityBuildings ON dbo.WaterTreatmentClosedLoopsWaterTests.FacNum = BaseComponents.dbo.ViewUniversityBuildings.FacilityNumber
             WHERE (BaseComponents.dbo.ViewUniversityBuildings.FacilityName IS NOT NULL)
             GROUP BY CONCAT(BaseComponents.dbo.ViewUniversityBuildings.FacilityName, ''-'', dbo.WaterTreatmentClosedLoopsWaterTests.LoopType), 
					  CONCAT(YEAR(dbo.WaterTreatmentClosedLoopsWaterTests.SurveyDate), ''-'', FORMAT(dbo.WaterTreatmentClosedLoopsWaterTests.SurveyDate, ''MM''))) AS innertable
GO', 
		@database_name=N'FacilitiesMaintenance', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Web Maps - 60 minutes', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190110, 
		@active_end_date=99991231, 
		@active_start_time=70000, 
		@active_end_time=170000, 
		@schedule_uid=N'b998cfed-808e-4aae-ba15-7e4700b6acf6'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


