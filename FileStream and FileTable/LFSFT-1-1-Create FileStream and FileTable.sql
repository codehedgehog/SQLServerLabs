/* Check SQL Server Edition */
/* https://support.microsoft.com/en-us/help/321185/how-to-determine-the-version,-edition-and-update-level-of-sql-server-a */
SELECT SERVERPROPERTY('productversion'), SERVERPROPERTY ('productlevel'), SERVERPROPERTY ('edition') 


/* 
FileStream:
* using VARBINARY(MAX) columns to store BLOBs: easily imported into varbinary(max) FILESTREAM columns using the single BLOB option with the OPENROWSET function 
* handles the storage details completely transparently, 
* automatically managing files in the file system, 
* maintaining pointers to those files in the rows that use them, 
* providing transactional consistency across the relational database and the NTFS file system
*/



-- Check the Filestream/FileTable Options
SELECT [dfo].[database_id], [dfo].[non_transacted_access], [dfo].[non_transacted_access_desc], [dfo].[directory_name] FROM [sys].[database_filestream_options] [dfo];  

SELECT DB_NAME([dfo].[database_id]) AS [DatabaseName], [dfo].[non_transacted_access], [dfo].[non_transacted_access_desc] FROM [sys].[database_filestream_options] [dfo];  

SELECT DB_NAME([dfo].[database_id]) AS [DatabaseName], [dfo].[non_transacted_access], [dfo].[non_transacted_access_desc] 
FROM   [sys].[database_filestream_options] [dfo] 
WHERE  DB_NAME([dfo].[database_id]) = 'LearnFileTable';



/* Enable File Stream for SQL Server */
/* --> Use "SQL Server Configuration Manager"  > "SQL Server Services" > "FILESTREAM" Properties */
/* --> Configure FILESTREAM Access Level for SQL Server instance */
/*     0 = Disabled, 1 = T-SQL Access Enabled, 2 = Full Access Enabled */
USE [master]
GO
EXEC [sp_configure] 'FILESTREAM Access Level',  2
GO
RECONFIGURE
GO
EXEC [sp_configure] [filestream_access_level];  -- See current config value and running value 
GO

USE [LearnFileTable]
GO
SELECT NAME,
       CASE
         WHEN value = 0 THEN 'FILESTREAM is Disabled for this instance'
         WHEN value = 1 THEN 'FILESTREAM is Enabled for Transact-SQL access for this instance'
         WHEN value = 2 THEN 'FILESTREAM is Enabled for Transact-SQL and Win32 for this instance'
       END AS [FILESTREAMOption]
FROM   [sys].[configurations]
WHERE  [NAME] = 'filestream access level';





/**************/
/* FILESTREAM */
/**************/
/*
For any table that defines one or more varbinary(max) FILESTREAM columns, special identifier column .
* Data type: uniqueidentifier
* Must include the ROWGUIDCOL attribute.
* Make it primary key or enforcing unique constraint --> Cannot contain NULLS
* Default value of this column can be next available GUID
Error message: A table that has FILESTREAM columns must have a nonnull unique column with the ROWGUIDCOL property.
*/


/* Use T-SQL to store and retrieve FILESTREAM data */
/* Create a FILESTREAM-enabled table */
/*
CREATE TABLE [PhotoAlbum] (
  [PhotoId] INT PRIMARY KEY, [PhotoDescription] VARCHAR(MAX), 
  [Photo] VARBINARY(MAX) FILESTREAM, 
  [RowId] UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL UNIQUE DEFAULT NEWSEQUENTIALID())
GO
*/

/* CREATE DATABASE [LearnFileStream] ON PRIMARY (NAME = [LearnFileStream_Data], FILENAME = '' */

-- Show the database filegroups
SELECT [fg].[name], [fg].[data_space_id],
       [fg].[type], [fg].[type_desc],
       [fg].[is_default], [fg].[is_system],
       [fg].[filegroup_guid], [fg].[log_filegroup_id],
       [fg].[is_read_only] 
FROM   [LearnFileTable].[sys].[filegroups] [fg]; 

-- List all files used in the database (MDF, LDF, FileTable)
SELECT [df].[name], [df].[type_desc], [df].[physical_name]
FROM   [LearnFileTable].[sys].[database_files] [df]


/* Create [LearnFileTable] DATABASE with FileTable */
/*
USE [master]
GO
IF EXISTS (SELECT [name] FROM [sys].[databases] WHERE [name] = N'LearnFileTable') DROP DATABASE [LearnFileTable]
GO
CREATE DATABASE [LearnFileTable]
ON -- Details of primary file group
   PRIMARY (NAME = LearnFileTable_Primary, FILENAME = N'D:\SQL_DATA\LearnFileTable.mdf', SIZE = 10MB, MAXSIZE = 50MB, FILEGROWTH = 5MB),
   -- Details of additional filegroup to be used to store data
   FILEGROUP [LFTDataGroup] (NAME = LearnFileTable_Data, FILENAME = N'D:\SQL_DATA\LearnFileTable_Data.ndf', SIZE = 10MB, MAXSIZE = 50MB, FILEGROWTH = 5MB),
   -- Details of special filegroup to be used to store FILESTREAM data
   -- FILENAME refers to the path and not to the actual file name. 
   -- It creates a folder which contains a filestream.hdr file and also a folder $FSLOG folder 
   FILEGROUP [LFTFileStreamDataGroup1] CONTAINS FILESTREAM DEFAULT (NAME = LearnFileTable_Blobs, FILENAME = N'D:\SQL_FILETABLE\LearnFileTable')
   -- Details of log file
   LOG ON ( Name = LearnFileTable_Log, FILENAME = 'L:\SQL_LOG\LearnFileTable.ldf', SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB) 
WITH FILESTREAM (NON_TRANSACTED_ACCESS = FULL, DIRECTORY_NAME = N'LearnFileTable') -- Other option for NON_TRANSACTED_ACCESS is READ_ONLY or OFF
GO
*/

/* FILESTREAM-enabling an existing database */
/*
ALTER DATABASE [LearnFileTable] ADD FILEGROUP [LFTFileStreamDataGroup1] CONTAINS FILESTREAM
ALTER DATABASE [LearnFileTable] ADD FILE (NAME = LearnFileTable_Blobs, FILENAME = 'D:\SQL_FILETABLE\LearnFileTable') TO FILEGROUP [LFTFileStreamDataGroup1];
*/

/* Creating a FileTable. */
/*
USE [LearnFileTable]
GO
CREATE TABLE [MyFirstFileTable] AS FileTable
WITH
(
  FileTable_Directory = 'MyFirstFileTable', -- FileTable directory name appear on the network share location and which will contain the data for this FileTable
  FileTable_Collate_Filename = database_default
);
GO
*/

USE [LearnFileTable];
GO

SELECT [fft].[stream_id], [fft].[file_stream], [fft].[name], [fft].[path_locator], [fft].[parent_path_locator],
       [fft].[is_directory], [fft].[file_type], [fft].[cached_file_size],
       [fft].[creation_time], [fft].[last_write_time], [fft].[last_access_time],
       [fft].[is_offline], [fft].[is_hidden], [fft].[is_readonly], [fft].[is_archive], [fft].[is_system], [fft].[is_temporary] 
FROM [dbo].[MyFirstFileTable] [fft] WITH (NOLOCK);





/*****************************/
/* IMPROVING I/O SCALABILITY */
/*****************************/

/* Multiple FILESTREAM Filegroups and Containers */

/*
CREATE DATABASE [MyDB]
  ON PRIMARY 
    (NAME = MyDB_data, FILENAME = 'C:\DB\MyDB_data.mdf'),
  FILEGROUP MyDB_docs CONTAINS FILESTREAM DEFAULT  -- designated FileStream FileGroup, being used for all FileStream that do not specify FileGroup
    (NAME = MyDB_docs1, FILENAME = 'D:\DB\MyDB_docs'),  -- single container
  FILEGROUP MyDB_photos CONTAINS FILESTREAM
    (NAME = MyDB_photos1, FILENAME = 'E:\DB\MyDB_photos'),  -- multiple containers
    (NAME = MyDB_photos2, FILENAME = 'F:\DB\MyDB_photos')
  LOG ON (NAME = MyDB_log, FILENAME = 'X:\DB\MyDB_log.ldf');
*/

/* The FileStream is put to drive D */
/*
CREATE TABLE [MyDB].[Candidate](
  [CandidateId] INT IDENTITY PRIMARY KEY,
  [BlobId] UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL UNIQUE,
  [Position] VARCHAR(MAX) NULL,
  [Resume] VARBINARY(MAX) FILESTREAM NULL)
FILESTREAM_ON MyDB_docs;
*/

/* The FileStream is put to drive E and drive F (multiple containers) */
/*
CREATE TABLE [MyDB].[Product](
  [ProductId] INT IDENTITY PRIMARY KEY,
  [BlobId] UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL UNIQUE,
  [ProductDescription] NVARCHAR(MAX) NULL,
  [Photo] VARBINARY(MAX) FILESTREAM NULL)
FILESTREAM_ON MyDB_photos;
*/
