BACKUP DATABASE [CampusEngineeringOperations] TO  DISK = N'C:\OneDrive\OneDrive - UW\Backups\CampusEngineeringOperations.bak' WITH  RETAINDAYS = 14, NOFORMAT, INIT,  NAME = N'CampusEngineeringOperations-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'CampusEngineeringOperations' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'CampusEngineeringOperations' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''CampusEngineeringOperations'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N'C:\OneDrive\OneDrive - UW\Backups\CampusEngineeringOperations.bak' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO

BACKUP DATABASE [CampusEngineeringOperations] TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\CampusEngineeringOperations.bak' WITH NOFORMAT, INIT,  NAME = N'CampusEngineeringOperations-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'CampusEngineeringOperations' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'CampusEngineeringOperations' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''CampusEngineeringOperations'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\CampusEngineeringOperations.bak' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO
