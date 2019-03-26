/**************/
/* HIERARCYID */
/**************/

USE [LearnFileTable]
GO


/*
	Sample Hierarchy 
	================

                                 Dave-6
                                    |
                   +----------------+---------------+
                   |                |               |
                Amy-46          John-271        Jill-119
                   |                |               |
              +----+----+           |               |
              |         |           |               |
         Cheryl-269  Wanda-389  Mary-272        Kevin-291
              |
         +----+----+
         |         |
    Richard-87   Jeff-90
*/



-- Create hierarchical table with a depth-first index
CREATE TABLE [dbo].[Employee]
(
   [NodeId]        hierarchyid PRIMARY KEY CLUSTERED,
   [NodeLevel]     AS [NodeId].GetLevel(),
   [EmployeeId]    int UNIQUE NOT NULL,
   [EmployeeName]  varchar(20) NOT NULL,
   [Title]         varchar(20) NULL
);
GO

SELECT [e].[NodeId].ToString() AS [NodeIdPath], [e].[NodeId], [e].[NodeLevel], 
       [e].[EmployeeId], [e].[EmployeeName], [e].[Title] 
FROM   [Employee] [e] WITH (NOLOCK);


-- GetRoot... retrieve the root node (Dave)
SELECT [e].[NodeId].ToString() AS [NodeIdPath], [dbo].[fnGetFullDisplayPath]([NodeId]) AS [NodeIdDisplayPath], [e].[NodeId], [e].[NodeLevel], 
       [e].[EmployeeId], [e].[EmployeeName], [e].[Title]
FROM   [dbo].[Employee] [e]
WHERE  [e].[NodeId] = hierarchyid::GetRoot();


---------------------------------------------------------------------------------------------------

-- Insert root node
INSERT INTO [Employee] ([NodeId], [EmployeeId], [EmployeeName], [Title])
VALUES      ([hierarchyid]::GetRoot(), 6, 'Dave', 'CEO') ;

-- Insert Amy as the first child beneath Dave
DECLARE @ParentEmployeeId hierarchyid = (SELECT [NodeId] FROM [Employee] WHERE [EmployeeId] = 6);
INSERT INTO [Employee]([NodeId], [EmployeeId], [EmployeeName], [Title])
 VALUES (@ParentEmployeeId.GetDescendant(NULL, NULL), 46, 'Amy', 'Marketing Specialist')

SELECT [NodeId].ToString() AS [NodeIdPath], * FROM [dbo].[Employee] [e];

---------------------------------------------------------------------------------------------------

-- Add the remaining employees
EXEC [dbo].[uspAddEmployee] @ParentEmployeeId = 6,   @EmployeeId = 271, @EmployeeName = 'John',    @EmployeeTitle = 'Marketing Specialist';
EXEC [dbo].[uspAddEmployee] @ParentEmployeeId = 6,   @EmployeeId = 119, @EmployeeName = 'Jill',    @EmployeeTitle = 'Marketing Specialist';
EXEC [dbo].[uspAddEmployee] @ParentEmployeeId = 46,  @EmployeeId = 269, @EmployeeName = 'Cheryl',  @EmployeeTitle = 'Marketing Assistant';
EXEC [dbo].[uspAddEmployee] @ParentEmployeeId = 46,  @EmployeeId = 389, @EmployeeName = 'Wanda',   @EmployeeTitle = 'Business Assistant';
EXEC [dbo].[uspAddEmployee] @ParentEmployeeId = 271, @EmployeeId = 272, @EmployeeName = 'Mary',    @EmployeeTitle = 'Marketing Assistant';
EXEC [dbo].[uspAddEmployee] @ParentEmployeeId = 119, @EmployeeId = 291, @EmployeeName = 'Kevin',   @EmployeeTitle = 'Marketing Intern';
EXEC [dbo].[uspAddEmployee] @ParentEmployeeId = 269, @EmployeeId = 87,  @EmployeeName = 'Richard', @EmployeeTitle = 'Business Intern';
EXEC [dbo].[uspAddEmployee] @ParentEmployeeId = 269, @EmployeeId = 90,  @EmployeeName = 'Jeff',    @EmployeeTitle = 'Business Intern';

SELECT NodeId.ToString() AS [NodeIdPath], * FROM [dbo].[Employee] [e];

---------------------------------------------------------------------------------------------------

-- Breadcrumb-style path showing all the employees in the chain 
SELECT [e].*, [NodeId].[ToString]() AS [NodeIdPath], [dbo].[fnGetFullDisplayPath]([NodeId]) AS [NodeIdDisplayPath]
FROM   [dbo].[Employee] [e]
ORDER  BY [NodeIdDisplayPath];

---------------------------------------------------------------------------------------------------

/*
Indexing hierarchyid Columns
Two types of of indexes: use one, the other, or both as your needs dictate
* Depth-first: create a primary key or unique index
* Breadth-first: create a composite index that includes a level column
*/

-- Create a breadth-first index
CREATE UNIQUE INDEX [IX_EmployeeBreadth] ON [dbo].[Employee]([NodeLevel], [NodeId]);
GO
