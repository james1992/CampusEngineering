BACKUP DATABASE [UtilitiesMasterPlan] TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\UtilitiesMasterPlan.bak' WITH  DESCRIPTION = N'Full backup of the Utilities Master Plan database',  RETAINDAYS = 7, NOFORMAT, NOINIT,  NAME = N'UtilitiesMasterPlan-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'UtilitiesMasterPlan' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'UtilitiesMasterPlan' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''UtilitiesMasterPlan'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\UtilitiesMasterPlan.bak' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO
