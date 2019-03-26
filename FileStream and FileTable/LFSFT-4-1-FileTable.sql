/************************/
/* SQL SERVER FILETABLE */
/************************/

SELECT * FROM [sys].[all_objects];

-- View/Returns FileTable settings for a database: database level, directory name, and transacted access settings
SELECT [db] = DB_NAME([database_id]), [directory_name], [non_transacted_access_desc] 
FROM   [sys].[database_filestream_options]  
-- WHERE  DB_NAME([database_id]) = 'LearnFileTable'
ORDER BY [db];

-- Discover FileTables in the database
SELECT * FROM [sys].[tables];
SELECT * FROM [sys].[tables] WHERE [name] LIKE '%MyFirstFileTable%';

-- Returns information about the FileTables in the database
SELECT [object_id], [is_enabled], [directory_name],[filename_collation_id], [filename_collation_name] FROM [sys].[filetables];

-- Returns all the system-generated FileTable defaults and constraints
SELECT [ft].[directory_name], 
       OBJECT_NAME([fsdo].[parent_object_id]) [FileTableName], [fsdo].[parent_object_id], 
       OBJECT_NAME([fsdo].[object_id]) AS [ObjectName], [fsdo].[object_id]
FROM   [sys].[filetable_system_defined_objects] [fsdo]
       LEFT JOIN [sys].[filetables] [ft] ON [fsdo].[parent_object_id] = [ft].[object_id]
ORDER  BY [fsdo].[parent_object_id];


-- Returns currently open non-transactional file and folder handles
SELECT * FROM [sys].[dm_filestream_non_transacted_handles];

-- Terminates handles to files open for non-transactional access
EXEC [sys].[sp_kill_filestream_non_transacted_handles] @table_name = N'', -- nvarchar(776)
                                                       @handle_id = 0;     -- int



/***********************/
/* FILETABLE Functions */
/***********************/
 -- FileTableRootPath: Returns the filepath for a specified FileTable (where the filetable has stored the files)
SELECT FileTableRootPath('[dbo].[FinDoc]'); 

-- GetFileNamespacePath: Returns the path for a specific file_stream instance (folder or file)
SELECT FileTableRootPath() + [file_stream].GetFileNamespacePath() AS [FullPath] FROM [dbo].[FinDoc]; 
SELECT [file_stream].GetFileNamespacePath(1, NULL) AS [FullPath] FROM [dbo].[FinDoc]; 

-- GetPathLocator: Returns the hierarchyidfor a specific path0
SELECT GetPathLocator('\\ITDEVSQL\MSSQLSERVER\LearnFileTable\Documents\New folder');





/***************************/
/* FILETABLE Prerequisites */
/***************************/
/*
* Set a root directory name for all FileTables in the database
  * Can be different than the database name
  * Surfaces as a folder in the Windows file share for the server instance

* Enable non-transactional FILESTREAM accesss
  * Traditional T-SQL and streaming  API access in still transactional
  * Can be enabled 

* Exposes a subfolder beneath the database folder in the emulated file system
  * Root directory for the FileTable
  * Named after the table (can be different)
  * Rows in the FileTable surface as files and folder beneath this subfolder 
    based on the folder structure dictated by the HIERARCHYID value in the PATH_LOCATOR column

*/

-- Creating a FileTable-Enabled database: Create an ordinary FILESTREAM-enabled database
/*
CREATE DATABASE [PhotoLibrary]
 ON PRIMARY 
   (NAME = PhotoLibrary_data,  FILENAME = 'C:\DB\PhotoLibrary_data.mdf'),
 FILEGROUP PhotoLibrary_photos CONTAINS FILESTREAM 
   (NAME = PhotoLibrary_photos1, FILENAME = 'C:\Db\Photos')
 LOG ON (NAME = PhotoLibrary_log, FILENAME = 'C:\Db\PhotoLibrary_log.ldf')
 WITH FILESTREAM
   (DIRECTORY_NAME = 'PhotoLibrary', NON_TRANSACTED_ACCESS = FULL)
GO
*/

-- FileTable-Enabling an Existing Database
/*
ALTER DATABASE [PhotoLibrary]
SET FILESTREAM (DIRECTORY_NAME = 'PhotoLibrary', NON_TRANSACTED_ACCESS = FULL)
*/

-- By default a folder named after the FileTable, appears the emulated in the file system
/*
CREATE TABLE [FinDoc] AS FILETABLE
  FILESTREAM_ON MyDB_Docs
  WITH (FILETABLE_DIRECTORY = 'My Financial Documents')

CREATE TABLE [FinDoc] AS FILETABLE
  FILESTREAM_ON LFTFileStreamDataGroup1
  WITH (FILETABLE_DIRECTORY = 'My Financial Documents')
*/

SELECT * FROM [dbo].[FinDoc];

-- Don't allow files in the root folder 
ALTER TABLE [dbo].[FinDoc] DROP CONSTRAINT [CK_FinDoc_NoRootFiles];
ALTER TABLE [dbo].[FinDoc] ADD CONSTRAINT [CK_FinDoc_NoRootFiles] CHECK ([is_directory] = 1 OR [path_locator].[GetLevel]() > 1);
GO


-- ========================================================================================

/*
FileTable Namespace: FileTable's hierarchical structure
* Machine name, instance share name, database name, FileTable name
* Root path is \\servername\instance\database\filetable

Improve performance for bulk operations
* Disabling the namespace disables constraints
* Temporarily disable the namespace to improve performance for bulk operations FileTableNamespace

*/

-- ========================================================================================




-- Create a FileTable (directory name defaults to table name, name column collation defaults to database collation)
CREATE TABLE [dbo].[Doc] AS FILETABLE;
-- Override the default FileTable directory name
ALTER TABLE [dbo].[Doc] SET (FILETABLE_DIRECTORY = 'Documents');
DROP TABLE [dbo].[Doc];

-- Specify the directory and collation when creating the table
CREATE TABLE [dbo].[Doc] AS FILETABLE 
  WITH (FILETABLE_DIRECTORY = 'Documents', FILETABLE_COLLATE_FILENAME = [SQL_Latin1_General_CP1_CI_AS]);  -- Case Insensitive, Accent Sensitive
DROP TABLE [dbo].[Doc];

/* Disable/Enable FileTable namespace */
ALTER TABLE [dbo].[Doc] DISABLE FILETABLE_NAMESPACE;
-- Constraints are disabled! Perform bulk updates very carefully...
ALTER TABLE [dbo].[Doc] ENABLE FILETABLE_NAMESPACE;
GO

-- Can't specify a case-sensitive collation for the Name column (filenames in Windows are case-insensitive)
CREATE TABLE [ForeignDoc] AS FILETABLE WITH (FILETABLE_COLLATE_FILENAME = [Japanese_CS_AS]);
CREATE TABLE [ForeignDoc] AS FILETABLE WITH (FILETABLE_COLLATE_FILENAME = [Japanese_CI_AS]);
DROP TABLE [ForeignDoc];
GO

