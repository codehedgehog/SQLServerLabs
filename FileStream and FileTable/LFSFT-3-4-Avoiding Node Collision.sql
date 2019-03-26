USE [LearnFileTable]
GO


-- Can't move to new parent with children in same position; e.g. move Kevin's subtree beneath John
DECLARE @OldParentNodeId hierarchyid = (SELECT NodeId FROM Employee WHERE EmployeeId = 291) -- Kevin
DECLARE @NewParentNodeId hierarchyid = (SELECT NodeId FROM Employee WHERE EmployeeId = 271) -- John

UPDATE Employee
 SET   NodeId = NodeId.GetReparentedValue(@OldParentNodeId, @NewParentNodeId)
 WHERE NodeId.IsDescendantOf(@OldParentNodeId) = 1 AND NodeId <> @OldParentNodeId -- Excludes Kevin

GO


/***********************************************************************/
/* Algorithm for generating random hierarchyid values for new children */
/***********************************************************************/
-- Get uniqueidentifer
DECLARE @NewId uniqueidentifier = NEWID()
SELECT @NewId

-- Convert to binary
DECLARE @NewIdBin binary(16) = CONVERT(binary(16), @NewId)
SELECT @NewIdBin

-- Breakdown into 3 binary parts
DECLARE @NewIdBin1 binary(6) = SUBSTRING(@NewIdBin, 1, 6)
DECLARE @NewIdBin2 binary(6) = SUBSTRING(@NewIdBin, 7, 6)
DECLARE @NewIdBin3 binary(4) = SUBSTRING(@NewIdBin, 13, 4)
SELECT @NewIdBin1, @NewIdBin2, @NewIdBin3

-- Convert each binary part into a bigint
DECLARE @NewIdInt1 bigint = CONVERT(bigint, @NewIdBin1)
DECLARE @NewIdInt2 bigint = CONVERT(bigint, @NewIdBin2)
DECLARE @NewIdInt3 bigint = CONVERT(bigint, @NewIdBin3)
SELECT @NewIdInt1, @NewIdInt2, @NewIdInt3

-- Convert each binary part into a string and concatenate with dots
DECLARE @NewIdStr varchar(max) = CONCAT(@NewIdInt1, '.', @NewIdInt2, '.', @NewIdInt3)
SELECT @NewIdStr

---------------------------------------------------------------------------------------------------


-- Reload the table
DELETE FROM Employee WHERE NodeId <> hierarchyid::GetRoot()

EXEC uspAddEmployee 6, 46, 'Amy', 'Marketing Specialist'
EXEC uspAddEmployee 6, 271, 'John', 'Marketing Specialist'
EXEC uspAddEmployee 6, 119, 'Jill', 'Marketing Specialist'
EXEC uspAddEmployee 46, 269, 'Cheryl', 'Marketing Assistant'
EXEC uspAddEmployee 46, 389, 'Wanda', 'Business Assistant'
EXEC uspAddEmployee 271, 272, 'Mary', 'Marketing Assistant'
EXEC uspAddEmployee 119, 291, 'Kevin', 'Marketing Intern'
EXEC uspAddEmployee 269, 87, 'Richard', 'Business Intern'
EXEC uspAddEmployee 269, 90, 'Jeff', 'Business Intern'


SELECT *, NodeId.ToString() AS NodeIdPath, dbo.fnGetFullDisplayPath(NodeId) AS NodeIdDisplayPath
 FROM Employee
 ORDER BY NodeIdDisplayPath


---------------------------------------------------------------------------------------------------

 -- Repeat the two previous Move operations (move Wanda from Amy to Jill, move Amy's subtree beneath Kevin)
DECLARE @EmployeeNodeId  hierarchyid = (SELECT NodeId FROM Employee WHERE EmployeeId = 389) -- Move Wanda
DECLARE @OldParentNodeId hierarchyid = @EmployeeNodeId.GetAncestor(1)                       --  from Amy
DECLARE @NewParentNodeId hierarchyid = (SELECT NodeId FROM Employee WHERE EmployeeId = 119) --  to Jill

UPDATE Employee
 SET   NodeId = NodeId.GetReparentedValue(@OldParentNodeId, @NewParentNodeId)
 WHERE NodeId = @EmployeeNodeId
GO

DECLARE @OldParentNodeId hierarchyid = (SELECT NodeId FROM Employee WHERE EmployeeId =  46) -- Move Amy tree
DECLARE @NewParentNodeId hierarchyid = (SELECT NodeId FROM Employee WHERE EmployeeId = 291) --  beneath Kevin

UPDATE Employee
 SET   NodeId = NodeId.GetReparentedValue(@OldParentNodeId, @NewParentNodeId)
 WHERE NodeId.IsDescendantOf(@OldParentNodeId) = 1 AND NodeId <> @OldParentNodeId -- Excludes Amy
GO


SELECT *, NodeId.ToString() AS NodeIdPath, dbo.fnGetFullDisplayPath(NodeId) AS NodeIdDisplayPath
 FROM Employee
 ORDER BY NodeIdDisplayPath

 ---------------------------------------------------------------------------------------------------


 -- No problem moving to new parent with children in same position
DECLARE @OldParentNodeId hierarchyid = (SELECT NodeId FROM Employee WHERE EmployeeId = 291) -- Move Kevin tree
DECLARE @NewParentNodeId hierarchyid = (SELECT NodeId FROM Employee WHERE EmployeeId = 271) --  beneath John

UPDATE Employee
 SET   NodeId = NodeId.GetReparentedValue(@OldParentNodeId, @NewParentNodeId)
 WHERE NodeId.IsDescendantOf(@OldParentNodeId) = 1 AND NodeId <> @OldParentNodeId -- Excludes Kevin

SELECT *, NodeId.ToString() AS NodeIdPath, dbo.fnGetFullDisplayPath(NodeId) AS NodeIdDisplayPath
 FROM Employee
 ORDER BY NodeIdDisplayPath

GO
