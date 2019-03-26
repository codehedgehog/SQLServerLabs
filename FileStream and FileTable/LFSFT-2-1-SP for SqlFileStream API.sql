USE [LearnFileTable];
GO

-- Returns currently open non-transactional file and folder handles
SELECT * FROM [sys].[dm_filestream_non_transacted_handles];

-- Terminates handles to files open for non-transactional access
sp_kill_filestream_non_transacted_handles


/* =================== Stored procedures to insert/select rows for streaming API =================== */

/*

-- Insert new photo row
CREATE PROCEDURE InsertPhotoRow(
	@PhotoId INT,
	@PhotoDescription VARCHAR(MAX))
AS
BEGIN
	INSERT INTO [dbo].[PhotoAlbum]([PhotoId], [PhotoDescription], Photo)
	 OUTPUT inserted.[PhotoId].PathName(), GET_FILESTREAM_TRANSACTION_CONTEXT()
	SELECT @PhotoId, @PhotoDescription, NULL
END
GO

-- Select photo image path + txn context
CREATE PROCEDURE SelectPhotoImageInfo(@PhotoId int)
AS
BEGIN
	SELECT [Photo].PathName(), GET_FILESTREAM_TRANSACTION_CONTEXT()
  FROM   [dbo].[PhotoAlbum] [pa] WITH (NOLOCK)
	WHERE  [pa].[PhotoId] = @PhotoId
END
GO

-- Select photo description
CREATE PROCEDURE SelectPhotoDescription(
	@PhotoId INT,
	@PhotoDescription VARCHAR(MAX) OUTPUT)
 AS
BEGIN
	SELECT @PhotoDescription = [PhotoDescription] FROM [dbo].[PhotoAlbum] [pa] WHERE [pa].[PhotoId] = @PhotoId;
END
GO

*/


SELECT [PhotoId], [PhotoDescription],  CAST([Photo] AS varchar) AS [BlobAsText], 
       DATALENGTH([Photo]) AS [BlobSize], [Photo], [RowId] 
FROM   [dbo].[PhotoAlbum] [pa] WITH (NOLOCK);

-- DELETE FROM [dbo].[PhotoAlbum] WHERE [PhotoID] = 5;