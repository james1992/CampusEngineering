BACKUP LOG [TransportationServices] TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\TransportationServices.bak' WITH  DESCRIPTION = N'Transaction log backup of Transportation Services to Local Disk.', NOFORMAT, NOINIT,  NAME = N'TransportationServices-Transcation Log', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'TransportationServices' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'TransportationServices' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''TransportationServices'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\TransportationServices.bak' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO