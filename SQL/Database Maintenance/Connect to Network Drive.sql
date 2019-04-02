EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO

EXEC sp_configure 'xp_cmdshell',1
GO
RECONFIGURE
GO

EXEC XP_CMDSHELL 'net use Y: "\\172.25.254.86\Backup Files" /user:Administrator goHuskies! /persistent:yes'