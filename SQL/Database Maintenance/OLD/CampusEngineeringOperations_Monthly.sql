DECLARE @MyFileName varchar(1000)
SELECT @MyFileName = (SELECT N'Y:\SQL\CampusEngineeringOperations_' + CONVERT(varchar(500),GetDate(),102) + '.bak')

BACKUP DATABASE [CampusEngineeringOperations] TO  DISK = @MyFileName WITH  COPY_ONLY,  DESCRIPTION = N'Full backup to Backup Files Network Drive of Campus Engineering & Operations', NOFORMAT, INIT, COMPRESSION,  NAME = N'CampusEngineeringOperations-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO

DECLARE @MyFileName varchar(1000)
SELECT @MyFileName = (SELECT N'Y:\SQL\CampusEngineeringOperations_' + CONVERT(varchar(500),GetDate(),102) + '.bak')

declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'CampusEngineeringOperations' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'CampusEngineeringOperations' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''CampusEngineeringOperations'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = @MyFileName WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO