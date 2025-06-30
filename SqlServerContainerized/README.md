# SQLSERVER BACKUP IN A DOCKER CONTAINER

## See the next link to watch tutorial:
https://www.youtube.com/watch?v=L1c4ZDRw0vg

## Download official samples of backup files (AdventureWorkes db):
https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks

## Docker commands:

1. To copy the backup file to the sqlserver container:
```docker
docker cp "/local/path/to/backup/file.bak" [container_name]:/var/opt/mssql
```

Example:
```docker
docker cp "./AdventureWorks2019.bak" sqlserver_db:/var/opt/mssql
```

2. Now, let's enter to the container bash to see if the copy command worked:
```docker
docker exec -it [sqlserver_container_name] 'bash'
```

Example:
```docker
docker exec -it sqlserver_db 'bash'
```

3. Execute the restore db script inside this folder (backup_db.sql).