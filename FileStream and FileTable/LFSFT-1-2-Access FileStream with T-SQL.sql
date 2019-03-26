USE [LearnFileTable];
GO


-- Add row #1 with a simple text BLOB using CAST
/*
INSERT INTO [dbo].[PhotoAlbum]([PhotoId], [PhotoDescription], [Photo]) 
  VALUES (1, 'This is a text file', CAST('BLOB' AS varbinary(MAX)));
 */

SELECT [PhotoId], [PhotoDescription],  CAST([Photo] AS varchar) AS [BlobAsText], 
       DATALENGTH([Photo]) AS [BlobSize], [Photo], [RowId] 
FROM   [dbo].[PhotoAlbum] [pa] WITH (NOLOCK);



-- Add row #2 with a small icon BLOB using inlined binary content
/*
INSERT INTO [dbo].[PhotoAlbum] (PhotoId, PhotoDescription, Photo)
 VALUES(2,
	'Document icon',
	0x4749463839610C000E00B30000FFFFFFC6DEC6C0C0C0000080000000D3121200000000000000000000000000000000000000000000000000000000000021F90401000002002C000000000C000E0000042C90C8398525206B202F1820C80584806D1975A29AF48530870D2CEDC2B1CBB6332EDE35D9CB27DCA554484204003B)
*/

SELECT [PhotoId], [PhotoDescription],  CAST([Photo] AS varchar) AS [BlobAsText], 
       DATALENGTH([Photo]) AS [BlobSize], [Photo], [RowId] 
FROM   [dbo].[PhotoAlbum] [pa] WITH (NOLOCK);


-- Add row #3 with an external image file imported using OPENROWSET with SINGLE_BLOB
/*
INSERT INTO [dbo].[PhotoAlbum] (PhotoId, PhotoDescription, Photo)
 VALUES(
	3,
	'Mountains',
	(SELECT BulkColumn FROM OPENROWSET(BULK 'T:\Wirawan\Ascent.jpg', SINGLE_BLOB) AS x))
*/

SELECT [PhotoId], [PhotoDescription],  CAST([Photo] AS varchar) AS [BlobAsText], 
       DATALENGTH([Photo]) AS [BlobSize], [Photo], [RowId] 
FROM   [dbo].[PhotoAlbum] [pa] WITH (NOLOCK);


/* =================== Use T-SQL to delete FILESTREAM data =================== */

-- Delete row #1
-- DELETE FROM [dbo].[PhotoAlbum] WHERE PhotoId = 1
SELECT [pa].* FROM [dbo].[PhotoAlbum] [pa] WITH (NOLOCK);

-- Forcing garbage collection won't delete the file without a BACKUP if using FULL recovery model
EXEC [dbo].[sp_filestream_force_garbage_collection];

-- Switch from FULL to SIMPLE recovery model
SELECT name, recovery_model_desc FROM sys.databases WHERE name = 'LearnFileTable'
ALTER DATABASE [LearnFileTable] SET RECOVERY SIMPLE
GO
SELECT name, recovery_model_desc FROM sys.databases WHERE name = 'LearnFileTable'

-- Forcing garbage collection will now delete the file immediately
EXEC [dbo].[sp_filestream_force_garbage_collection];

