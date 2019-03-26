
/****************************************/
/* QUERYING AND MANIPULATING FILETABLES */ 
/****************************************/

USE [LearnFileTable];
GO

-- Show path_locator default constraint
SELECT [d].[name], [d].[definition] 
FROM   [sys].[all_columns] AS [c]
       INNER JOIN [sys].[tables] AS [t] ON [c].[object_id] = [t].[object_id]
	     INNER JOIN [sys].[schemas] AS [s] ON [t].[schema_id] = [s].[schema_id]
	     INNER JOIN [sys].[default_constraints] AS [d] ON [c].[default_object_id] = [d].[object_id]
WHERE  [s].[name] = 'dbo' AND [t].[name] = 'Doc' AND [c].[name] = 'path_locator';
GO

SELECT * FROM [dbo].[FinDoc];


EXEC [dbo].[uspAddItem]  @Parent = '', @Name = 'CompanyLogo.png', @File = 'T:\Wirawan\csuf-logo-color.jpg';

-- Create folder \Financial
EXEC [dbo].[uspAddItem] @Parent = '', @Name = 'Financial';

-- Add file to \Financial folder
EXEC [dbo].[uspAddItem] @Parent = '\Financial', @Name = 'CompanyLogo.png', @File = 'T:\Wirawan\csuf-logo-color.jpg';


-- Create folder \Financial\Budget
EXEC [dbo].[uspAddItem] @Parent = '\Financial', @Name = 'Budget';

-- Create folder \Financial\Budget\2014
EXEC [dbo].[uspAddItem] @Parent = '\Financial\Budget', @Name = '2014';

-- Add files to 2014 folder
EXEC [dbo].[uspAddItem] @Parent = '\Financial\Budget\2014', @Name = 'ReadMe2014.txt', @File = 'T:\Wirawan\Dummy.txt';
EXEC [dbo].[uspAddItem] @Parent = '\Financial\Budget\2014', @Name = 'DinnerReceipt.png', @File = 'T:\Wirawan\Dummy.png';
EXEC [dbo].[uspAddItem] @Parent = '\Financial\Budget\2014', @Name = 'TravelBudget.rtf', @File = 'T:\Wirawan\Demo\Dummy.rtf';


-- Create folder \Financial\2013
EXEC [dbo].[uspAddItem] @Parent = '\Financial\Budget', @Name = '2013';

-- Add files to 2013 folder
EXEC [dbo].[uspAddItem] @Parent = '\Financial\Budget\2013', @Name = 'ReadMe2013.txt', @File = 'T:\Wirawan\Dummy.txt';
EXEC [dbo].[uspAddItem] @Parent = '\Financial\Budget\2013', @Name = 'Entertainment.png', @File = 'T:\Wirawan\Dummy.png';

GO


-- Move DinnerReceipt.png from 2014 folder to 2013 folder
EXEC [dbo].[uspMoveItem] '\Financial\Budget\2014\DinnerReceipt.png', '\Financial\Budget\2013';


-- Delete folders and files

-- Delete ReadMe2014.txt from 2014 folder
EXEC uspDeleteItem '\Financial\Budget\2014\ReadMe2014.txt'

-- Delete \Financial\Budget folder
EXEC uspDeleteItem '\Financial\Budget\2014'




/**********************/
/* Get Child Subtrees */
/**********************/
EXEC [dbo].[uspGetChildItems] @FullName = '\Financial';
EXEC [dbo].[uspGetChildItems] @FullName = '\Financial\Budget';
EXEC [dbo].[uspGetChildItems] @FullName = '\Financial\Budget\2013';
EXEC [dbo].[uspGetChildItems] @FullName = '\Financial\Budget\2014';



/***********************/
/* Show Parent Folders */
/***********************/
EXEC [dbo].[uspGetParentItems] @FullName = '\Financial';
EXEC [dbo].[uspGetParentItems] @FullName = '\Financial\Budget';
EXEC [dbo].[uspGetParentItems] @FullName = '\Financial\Budget\2013';
EXEC [dbo].[uspGetParentItems] @FullName = '\Financial\Budget\2014';
EXEC [dbo].[uspGetParentItems] @FullName = '\Financial\Budget\2014\TravelBudget.rtf';
