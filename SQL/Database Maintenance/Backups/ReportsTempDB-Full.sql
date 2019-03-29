BACKUP DATABASE [ReportsTempDB] TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\ReportsTempDB.bak' WITH  DESCRIPTION = N'Full backup to Local Disk of Reports Temp DB',  RETAINDAYS = 7, NOFORMAT, INIT,  NAME = N'ReportsTempDB-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'ReportsTempDB' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'ReportsTempDB' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''ReportsTempDB'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\ReportsTempDB.bak' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO