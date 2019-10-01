DECLARE @MyFileName varchar(1000)
SELECT @MyFileName = (SELECT N'Y:\SQL\FacilitiesConstruction_' + CONVERT(varchar(500),GetDate(),102) + '.bak')

BACKUP DATABASE [FacilitiesConstruction] TO  DISK = @MyFileName WITH  COPY_ONLY, DESCRIPTION = N'Full backup to Backup Files Network Drive of Base Components', NOFORMAT, NOINIT, COMPRESSION,  NAME = N'FacilitiesConstruction-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO

DECLARE @MyFileName varchar(1000)
SELECT @MyFileName = (SELECT N'Y:\SQL\FacilitiesConstruction_' + CONVERT(varchar(500),GetDate(),102) + '.bak')

declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'FacilitiesConstruction' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'FacilitiesConstruction' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''FacilitiesConstruction'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = @MyFileName WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO