DECLARE @MyFileName varchar(1000)
SELECT @MyFileName = (SELECT N'Y:\SQL\BaseComponents_' + CONVERT(varchar(500),GetDate(),102) + '.bak')

BACKUP DATABASE [BaseComponents] TO  DISK = @MyFileName WITH  COPY_ONLY, DESCRIPTION = N'Full backup to Backup Files Network Drive of Base Components', NOFORMAT, NOINIT, COMPRESSION,  NAME = N'BaseComponents-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO

DECLARE @MyFileName varchar(1000)
SELECT @MyFileName = (SELECT N'Y:\SQL\BaseComponents_' + CONVERT(varchar(500),GetDate(),102) + '.bak')

declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'BaseComponents' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'BaseComponents' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''BaseComponents'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = @MyFileName WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO