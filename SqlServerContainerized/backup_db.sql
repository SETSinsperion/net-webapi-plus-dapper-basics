-- 1. Search for directories where to copy the backup file.
/*
sp_helpfile
*/

/*
QUERY RESULT EXAMPLE:
name	fileid	filename	filegroup	size	maxsize	growth	usage
master	1	/var/opt/mssql/data/master.mdf	PRIMARY	4608 KB	Unlimited	10%	data only
mastlog	2	/var/opt/mssql/data/mastlog.ldf	NULL	2048 KB	Unlimited	10%	log only
*/

-- 2. Make sure the database you're restoring to doesn't already exist:
IF DB_ID('AdventureWorks') IS NOT NULL
BEGIN
    ALTER DATABASE AdventureWorks SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE AdventureWorks;
END

-- 3. Restore the .bak file:
RESTORE DATABASE AdventureWorks
FROM DISK = '/var/opt/mssql/AdventureWorks2019.bak'
WITH FILE = 1,
MOVE 'AdventureWorks2019' TO '/var/opt/mssql/data/AdventureWorks2019.mdf',
MOVE 'AdventureWorks2019_log' TO '/var/opt/mssql/data/AdventureWorks2019_log.ldf',
NOUNLOAD,
STATS = 5;

-- Make the database multi-user again after restoration:
ALTER DATABASE AdventureWorks SET MULTI_USER;

-- 4. Test the restored db using a query:
USE AdventureWorks;
SELECT TOP 1000 * FROM Sales.Currency;