--*************************************************************************--
-- Title: Assignment07
-- Author: SGodyn
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2025-11-25,SGodyn,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_SGodyn')
	 Begin 
	  Alter Database [Assignment07DB_SGodyn] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_SGodyn;
	 End
	Create Database Assignment07DB_SGodyn;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_SGodyn;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
GO

-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

-- <Put Your Code Here> --
-- show work
--SELECT 
--	ProductName AS [ProductName],
--	UnitPrice AS [UnitPrice]
--FROM dbo.vProducts
--ORDER BY ProductName;
--GO

SELECT 
	ProductName AS [ProductName],
	FORMAT(UnitPrice,'C','en-US') AS [UnitPrice]
FROM dbo.vProducts
ORDER BY ProductName;
GO

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.
-- <Put Your Code Here> --
-- show work
--SELECT
--	c.CategoryName,
--	p.ProductName,
--	p.UnitPrice
--FROM vCategories as c
--INNER JOIN vProducts as p
--	ON c.CategoryID = p.CategoryID
--ORDER BY 1,2;
--go

SELECT
	c.CategoryName AS [CategoryName],
	p.ProductName AS [ProductName],
	FORMAT(p.UnitPrice,'C','en-US') AS [UnitPrice]
FROM vCategories as c
INNER JOIN vProducts as p
	ON c.CategoryID = p.CategoryID
ORDER BY 1,2;
GO

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --
-- show work
--SELECT 
--	p.ProductName AS [ProductName],
--	i.InventoryDate AS [InventoryDate],
--	i.Count AS [InventoryCount]
--FROM vProducts AS p
--INNER JOIN vInventories AS i
--	ON p.ProductID = i.ProductID
--ORDER BY ProductName, InventoryDate;
--go

SELECT
	p.ProductName AS [ProductName],
	FORMAT(i.InventoryDate,'MMMM, yyyy') AS [InventoryDate],
	i.Count AS [InventoryCount]
FROM vProducts as p
INNER JOIN vInventories as i
	ON p.ProductID = i.ProductID
ORDER BY ProductName, i.InventoryDate;
GO

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --
-- show work
--CREATE -- drop
--VIEW vProductInventories
----WITH SCHEMABINDING - cannot schema bind because vProducts is invalid for schema binding. Names must be in two-part format and object cannot reference itself.
--AS
--	SELECT TOP 1000000000
--		p.ProductName AS [ProductName],
--		i.InventoryDate AS [InventoryDate],
--		i.Count AS [InventoryCount]
--	FROM vProducts as p
--	INNER JOIN vInventories as i
--		ON p.ProductID = i.ProductID
--	ORDER BY p.ProductName, i.InventoryDate;
--go
--SELECT * FROM vProductInventories;

CREATE -- drop
VIEW vProductInventories
AS
	SELECT TOP 1000000000
		p.ProductName AS [ProductName],
		FORMAT(i.InventoryDate, 'MMMM, yyyy') AS [InventoryDate],
		i.Count AS [InventoryCount]
	FROM vProducts as p
	INNER JOIN vInventories as i
		ON p.ProductID = i.ProductID
	ORDER BY p.ProductName, i.InventoryDate;
go
-- Check that it works: Select * From vProductInventories;
SELECT * FROM vProductInventories;
go

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --
-- show work
--CREATE -- drop
--VIEW vCategoryInventories
--AS
--	SELECT TOP 1000000000
--		CategoryName,
--		InventoryDate,
--		Count AS [InventoryCount]
--	FROM vCategories AS c
--	INNER JOIN vProducts as p
--		ON c.CategoryID = p.CategoryID
--	INNER JOIN vInventories AS i
--		ON p.ProductID = i.ProductID
--	ORDER BY c.CategoryName, i.InventoryDate;

--CREATE -- drop
--VIEW vCategoryInventories
--AS
--	SELECT TOP 1000000000
--		CategoryName,
--		FORMAT(InventoryDate,'MMMM, yyyy') AS [InventoryDate],
--		Count AS [InventoryCount]
--	FROM vCategories AS c
--	INNER JOIN vProducts as p
--		ON c.CategoryID = p.CategoryID
--	INNER JOIN vInventories AS i
--		ON p.ProductID = i.ProductID
--	ORDER BY c.CategoryName, i.InventoryDate;

CREATE -- drop
VIEW vCategoryInventories
AS
	SELECT TOP 1000000000
		c.CategoryName AS [CategoryName],
		FORMAT(i.InventoryDate,'MMMM, yyyy') AS [InventoryDate],
		SUM(i.Count) AS [InventoryCountByCategory]
	FROM vCategories AS c
	INNER JOIN vProducts as p
		ON c.CategoryID = p.CategoryID
	INNER JOIN vInventories AS i
		ON p.ProductID = i.ProductID
	GROUP BY c.CategoryName, i.InventoryDate
	ORDER BY c.CategoryName, i.InventoryDate;
go
-- Check that it works: Select * From vCategoryInventories;
SELECT * FROM vCategoryInventories;
go

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

-- <Put Your Code Here> --
-- show work
--CREATE -- drop
--VIEW vProductInventoriesWithPreviousMonthCounts
--AS
--	SELECT TOP 1000000000
--		ProductName AS [ProductName],
--		InventoryDate AS [InventoryDate],
--		InventoryCount AS [InventoryCount]
--	FROM vProductInventories
--	ORDER BY ProductName, InventoryDate;

--CREATE -- drop
--VIEW vProductInventoriesWithPreviousMonthCounts
--AS
--	SELECT TOP 1000000000
--		ProductName AS [ProductName],
--		InventoryDate AS [InventoryDate],
--		InventoryCount AS [InventoryCount],
--		[PreviousMonthCount] = LAG(InventoryCount) OVER (ORDER BY InventoryDate)
--	FROM vProductInventories
--	ORDER BY ProductName, InventoryDate;
--go

CREATE -- drop
VIEW vProductInventoriesWithPreviousMonthCounts
AS
	SELECT TOP 1000000000
		ProductName AS [ProductName],
		InventoryDate AS [InventoryDate],
		--[InventoryMonth] = dbo.fnInventoryMonth (InventoryDate),
		InventoryCount AS [InventoryCount],
		[PreviousMonthCount] = ISNULL(LAG(InventoryCount) 
										OVER (PARTITION BY ProductName
										ORDER BY CONVERT(DATE, InventoryDate)),0)
	FROM vProductInventories
	ORDER BY ProductName, CONVERT(DATE,InventoryDate);
GO
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;
SELECT * FROM vProductInventoriesWithPreviousMonthCounts;
go

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --
-- show work
--CREATE -- drop
--VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs
--AS
--	SELECT
--		ProductName,
--		InventoryDate,
--		InventoryCount,
--		PreviousMonthCount,
--		CountVsPreviousCountKPI = CASE
--									WHEN (InventoryCount - PreviousMonthCount) > 0 THEN 1
--									WHEN (InventoryCount - PreviousMonthCount) = 0 THEN 0
--									WHEN (InventoryCount - PreviousMonthCount) < 0 THEN -1			
--								  END
--	FROM vProductInventoriesWithPreviousMonthCounts;
--GO

CREATE -- drop
VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs
AS
	SELECT TOP 1000000000
		ProductName AS [ProductName],
		InventoryDate AS [InventoryDate],
		InventoryCount AS [InventoryCount],
		PreviousMonthCount AS [PreviousMonthCount],
		CountVsPreviousCountKPI = CASE
									WHEN (InventoryCount - PreviousMonthCount) > 0 THEN 1
									WHEN (InventoryCount - PreviousMonthCount) = 0 THEN 0
									WHEN (InventoryCount - PreviousMonthCount) < 0 THEN -1			
								  END
	FROM vProductInventoriesWithPreviousMonthCounts
	ORDER BY ProductName, CONVERT(DATE,InventoryDate);
GO

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --
-- Function to return a table based on a passed KPI value
CREATE -- drop
FUNCTION dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs (@KPI INT)
RETURNS TABLE
	RETURN	
			SELECT TOP 1000000000
				ProductName AS [ProductName],
				InventoryDate AS [InventoryDate],
				InventoryCount AS [InventoryCount],
				PreviousMonthCount AS [PreviousMonthCount],
				CountVsPreviousCountKPI AS [CountVsPreviousCountKPI]
			FROM vProductInventoriesWithPreviousMonthCountsWithKPIs as vKPI
			WHERE vKPI.CountVsPreviousCountKPI = @KPI
			ORDER BY vKPI.ProductName, CONVERT(DATE, vKPI.InventoryDate)
GO

--Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
go

/***************************************************************************************/
-- Interpretted function for Question 8 incorrectly...saving notes here
-- Function to calculate KPI values.  Pass in InventoryCount, PreviousMonthCount; return KPI integer value
--CREATE -- drop
--FUNCTION dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs (@InvCount INT, @PrevMonthCount INT)
--RETURNS INT
--AS
--	BEGIN
--		-- Set up temp variables
--		DECLARE @InventoryCountDifference AS INT
--		DECLARE @KPI AS INT

--		-- Calculate difference between current month Inventory count and previous month inventory count
--		SET @InventoryCountDifference = (@InvCount - @PrevMonthCount)

--		-- Determine KPI
--		SET @KPI = CASE
--					WHEN @InventoryCountDifference > 0 THEN 1
--					WHEN @InventoryCountDifference = 0 THEN 0
--					WHEN @InventoryCountDifference < 0 THEN -1			
--				   END

--		-- return KPI result
--		RETURN @KPI