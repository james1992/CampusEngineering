BACKUP DATABASE [FacilitiesConstruction] TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\FacilitiesConstruction.bak' WITH  DESCRIPTION = N'Full backup to Local Disk of Facilities Construction',  RETAINDAYS = 7, NOFORMAT, INIT,  NAME = N'FacilitiesConstruction-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'FacilitiesConstruction' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'FacilitiesConstruction' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''FacilitiesConstruction'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\FacilitiesConstruction.bak' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO