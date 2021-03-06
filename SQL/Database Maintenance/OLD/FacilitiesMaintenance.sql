BACKUP DATABASE [FacilitiesMaintenance] TO  DISK = N'C:\OneDrive\OneDrive - UW\Backups\FacilitiesMaintenance.bak' WITH  COPY_ONLY,  DESCRIPTION = N'Full backup to Office365 of Facilities Maintenance',  RETAINDAYS = 1, NOFORMAT, INIT,  NAME = N'FacilitiesMaintenance-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'FacilitiesMaintenance' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'FacilitiesMaintenance' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''FacilitiesMaintenance'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N'C:\OneDrive\OneDrive - UW\Backups\FacilitiesMaintenance.bak' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO

BACKUP DATABASE [FacilitiesMaintenance] TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\FacilitiesMaintenance.bak' WITH  DESCRIPTION = N'Full backup to Local Disk of Facilities Maintenance',  RETAINDAYS = 7, NOFORMAT, INIT,  NAME = N'FacilitiesMaintenance-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'FacilitiesMaintenance' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'FacilitiesMaintenance' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''FacilitiesMaintenance'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\FacilitiesMaintenance.bak' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO