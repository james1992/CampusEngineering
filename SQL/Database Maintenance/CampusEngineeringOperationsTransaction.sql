BACKUP LOG [CampusEngineeringOperations] TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\CampusEngineeringOperations.bak' WITH  DESCRIPTION = N'Transaction log backup of Campus Engineering & Operations to Local Disk.', NOFORMAT, NOINIT,  NAME = N'CampusEngineeringOperations-Transcation Log', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'CampusEngineeringOperations' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'CampusEngineeringOperations' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''CampusEngineeringOperations'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\CampusEngineeringOperations.bak' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO