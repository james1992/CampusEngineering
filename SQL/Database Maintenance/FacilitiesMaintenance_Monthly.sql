DECLARE @MyFileName varchar(1000)
SELECT @MyFileName = (SELECT N'C:\OneDrive\OneDrive - UW\Backups\FacilitiesMaintenance_' + CONVERT(varchar(500),GetDate(),102) + '.bak')

BACKUP DATABASE [FacilitiesMaintenance] TO  DISK = @MyFileName WITH  RETAINDAYS = 14, NOFORMAT, INIT,  NAME = N'FacilitiesMaintenance-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO

DECLARE @MyFileName varchar(1000)
SELECT @MyFileName = (SELECT N'C:\OneDrive\OneDrive - UW\Backups\FacilitiesMaintenance_' + CONVERT(varchar(500),GetDate(),102) + '.bak')

declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'FacilitiesMaintenance' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'FacilitiesMaintenance' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''FacilitiesMaintenance'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = @MyFileName WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO