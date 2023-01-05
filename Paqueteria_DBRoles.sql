											
											--Crear db_Owner (db Owner)--

USE [master]
GO
CREATE LOGIN [Owner] WITH PASSWORD=N'123', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
USE [Paqueteria]
CREATE USER [Owner] FOR LOGIN [Owner]
ALTER ROLE [db_owner] ADD MEMBER [Owner]


											--Crear SecuAdmin (Security Admin)-- 

USE [master]
GO
CREATE LOGIN [SecuAdmin] WITH PASSWORD=N'123', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
USE [Paqueteria]
CREATE USER [SecuAdmin] FOR LOGIN [SecuAdmin]
ALTER ROLE [db_securityadmin] ADD MEMBER [SecuAdmin]
GO
--DENY SELECT ON Cliente TO OnlyReader
--GRANT SELECT ON Cliente TO OnlyReader


											--Crear Backup_Creator (db_BackUpOperator)-- 

USE [master]
CREATE LOGIN [BackUp_Creator] WITH PASSWORD=N'123', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
USE [Paqueteria]
CREATE USER [BackUp_Creator] FOR LOGIN [BackUp_Creator]
ALTER ROLE [db_backupoperator] ADD MEMBER [BackUp_Creator]


											--Crear Backup_Reader (db_BackUpOperator and db_DataReader)-- 

USE [master]
CREATE LOGIN Backup_Reader WITH PASSWORD=N'123', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
USE [Paqueteria]
CREATE USER [Backup_Reader] FOR LOGIN [Backup_Reader]
ALTER ROLE [db_backupoperator] ADD MEMBER [BackUp_Creator]
ALTER ROLE [db_datareader] ADD MEMBER [Backup_Reader]


											--Crear DDL_USER (db_ddladmin)-- 

USE [master]
CREATE LOGIN DDL_USER WITH PASSWORD=N'123', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
USE [Paqueteria]
CREATE USER DDL_USER FOR LOGIN DDL_USER
ALTER ROLE [db_ddladmin] ADD MEMBER DDL_USER



											--Crear OnlyReader (Data Reader)-- 
USE [master]
CREATE LOGIN [OnlyReader] WITH PASSWORD=N'123', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
USE [Paqueteria]
CREATE USER [OnlyReader] FOR LOGIN [OnlyReader]
ALTER ROLE [db_datareader] ADD MEMBER [OnlyReader]


											-- OnlyWriter (Data Writer)--
USE [master]
GO
CREATE LOGIN [OnlyWriter] WITH PASSWORD=N'123', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
USE [Paqueteria]
CREATE USER [OnlyWriter] FOR LOGIN [OnlyWriter]
ALTER ROLE [db_datawriter] ADD MEMBER [OnlyWriter]
GO
