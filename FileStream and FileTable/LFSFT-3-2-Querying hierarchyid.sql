/***********************************/
/* HIERARCYID: QUERYING HIERARCYID */
/***********************************/

USE [LearnFileTable];
GO

-- GetRoot... retrieve the root node (Dave)
SELECT [e].[NodeId].ToString() AS [NodeIdPath], [dbo].fnGetFullDisplayPath([NodeId]) AS [NodeIdDisplayPath], [e].[NodeId], [e].[NodeLevel], 
       [e].[EmployeeId], [e].[EmployeeName], [e].[Title]
FROM   [dbo].[Employee] [e]
WHERE  [e].[NodeId] = hierarchyid::GetRoot();



-- IsDescendantOfMethod... retrieve a subtree beginning with Amy
DECLARE @AmyNodeId HIERARCHYID = (SELECT [e].[NodeId] FROM [dbo].[Employee] [e] WHERE [EmployeeId] = 46);
SELECT  [e].[NodeId].ToString() AS [NodeIdPath], [dbo].fnGetFullDisplayPath([e].[NodeId]) AS [NodeIdDisplayPath], 
        [e].[NodeId], [e].[NodeLevel],
        [e].[EmployeeId], [e].[EmployeeName], [e].[Title]
FROM    [dbo].[Employee] [e]
WHERE   [e].[NodeId].IsDescendantOf(@AmyNodeId) = 1
ORDER   BY [NodeIdDisplayPath];



-- GetAncestorMethod... retrieve Amy's direct children (1 level down)
DECLARE @AmyNodeId HIERARCHYID = (SELECT [e].[NodeId] FROM [dbo].[Employee] [e] WHERE [EmployeeId] = 46);
SELECT  [e].[NodeId].ToString() AS [NodeIdPath], [dbo].fnGetFullDisplayPath([e].[NodeId]) AS [NodeIdDisplayPath], 
        [e].[NodeId], [e].[NodeLevel],
        [e].[EmployeeId], [e].[EmployeeName], [e].[Title]
FROM    [dbo].[Employee] [e]
WHERE   [e].[NodeId].GetAncestor(1) = @AmyNodeId
ORDER   BY [NodeIdDisplayPath];



-- GetAncestorMethod... retrieve Dave's grandchildren (2 levels down)
DECLARE @DaveNodeId HIERARCHYID = (SELECT [e].[NodeId] FROM [dbo].[Employee] [e] WHERE [EmployeeId] = 6);
SELECT  [e].[NodeId].ToString() AS [NodeIdPath], [dbo].fnGetFullDisplayPath([e].[NodeId]) AS [NodeIdDisplayPath], 
        [e].[NodeId], [e].[NodeLevel],
        [e].[EmployeeId], [e].[EmployeeName], [e].[Title]
FROM    [dbo].[Employee] [e]
WHERE   [e].[NodeId].GetAncestor(2) = @DaveNodeId
ORDER   BY [NodeIdDisplayPath];


