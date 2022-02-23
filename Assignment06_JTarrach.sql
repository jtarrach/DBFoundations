--*************************************************************************--
-- Title: Assignment06
-- Author: Jennifer Tarrach
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2022-02-19,Jennifer Tarrach,Created File
-- 2022-02-20,Jennifer Tarrach, Question1-
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_JTarrach')
	 Begin 
	  Alter Database [Assignment06DB_JTarrach] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_JTarrach;
	 End
	Create Database Assignment06DB_JTarrach;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_JTarrach;

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
,[UnitPrice] [mOney] NOT NULL
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
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
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
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

--Select * From Categories;
--GO

--Select c.CategoryID
--		,c.CategoryName
--	From Categories as c;
--Go

--Create --Drop
--View vCategories
--AS
--	Select c.CategoryID
--		,c.CategoryName
--	From Categories as c;
--GO
--Select * From [dbo].[vCategories]

GO
Create --Drop
View vCategories
With Schemabinding
As
	Select   c.CategoryID
			,c.CategoryName
	From dbo.Categories as c;
GO

Select * From [dbo].[vCategories]
GO

--Select * From Products;
--GO

Create --Drop
View vProducts
With Schemabinding
As
	Select   p.ProductID
			,p.ProductName
			,p.CategoryID
			,p.UnitPrice
	From dbo.Products as p;
GO

Select * From [dbo].[vProducts]
GO

--Select * From Inventories;
--GO

Create --Drop
View vInventories
With Schemabinding
As
	Select   i.InventoryID
			,i.InventoryDate
			,i.EmployeeID
			,i.ProductID
			,i.Count
	From dbo.Inventories as i;
GO

Select * From [dbo].[vInventories]
GO

--Select * From Employees;
--GO

Create --Drop
View vEmployees
With Schemabinding
As
	Select   e.EmployeeID
			,e.EmployeeFirstName
			,e.EmployeeLastName
			,e.ManagerID
			
	From dbo.Employees as e;
GO

Select * From [dbo].[vEmployees]
GO

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Use Assignment06DB_JTarrach;
Deny Select On Categories to Public
Grant Select On vCategories to Public

Deny Select On Products to Public
Grant Select On vProducts to Public

Deny Select On Inventories to Public
Grant Select On vInventories to Public

Deny Select On Employees to Public
Grant Select On vEmployees to Public
GO

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

Create --Drop
View vProductsByCategories
As
	SELECT Top 1000
			  c.CategoryName
			, p.ProductName
			, p.UnitPrice
		FROM vProducts as p INNER JOIN vCategories as c
			ON p.CategoryID = c.CategoryID
		ORDER BY c.CategoryName, p.ProductName
;
GO

Select * From [dbo].[vProductsByCategories]
GO

-- Here is an example of some rows selected from the view:
-- CategoryName ProductName       UnitPrice
-- Beverages    Chai              18.00
-- Beverages    Chang             19.00
-- Beverages    Chartreuse verte  18.00


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

Create --Drop
View vInventoriesByProductsByDates
As
	SELECT Top 1000
			  p.ProductName
			, i.InventoryDate
			, i.Count
		FROM vInventories as i INNER JOIN vProducts as p
			ON i.ProductID = p.ProductID
		ORDER BY p.ProductName ASC, i.InventoryDate ASC, i.Count ASC
;
GO

Select * From [dbo].[vInventoriesByProductsByDates]
GO
-- Here is an example of some rows selected from the view:
-- ProductName	  InventoryDate	Count
-- Alice Mutton	  2017-01-01	  0
-- Alice Mutton	  2017-02-01	  10
-- Alice Mutton	  2017-03-01	  20
-- Aniseed Syrup	2017-01-01	  13
-- Aniseed Syrup	2017-02-01	  23
-- Aniseed Syrup	2017-03-01	  33


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

Create --Drop
View vInventoriesByEmployeesByDates
As
SELECT Top 1000
		  i.InventoryDate
		, e.EmployeeFirstName + ' ' + e.EmployeeLastName as 'Employee Name'
	FROM vInventories as i INNER JOIN vEmployees as e
		ON i.EmployeeID = e.EmployeeID
	GROUP BY i.InventoryDate, e.EmployeeFirstName, e.EmployeeLastName
	ORDER BY i.InventoryDate
;
GO

Select * From [dbo].[vInventoriesByEmployeesByDates]
GO

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

Create --Drop
View vInventoriesByProductsByCategories
As
SELECT Top 10000
			   c.CategoryName
			 , p.ProductName
			 , i.InventoryDate
			 , i.Count
	FROM vInventories as i 
		INNER JOIN vProducts as p
		ON i.ProductID = p.ProductID
		INNER JOIN vCategories as c
		ON p.CategoryID=c.CategoryID
	ORDER BY c.CategoryName, p.ProductName, i.InventoryDate, i.Count
;
GO

Select * From [dbo].[vInventoriesByProductsByCategories]
GO

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- CategoryName	ProductName	InventoryDate	Count
-- Beverages	  Chai	      2017-01-01	  39
-- Beverages	  Chai	      2017-02-01	  49
-- Beverages	  Chai	      2017-03-01	  59
-- Beverages	  Chang	      2017-01-01	  17
-- Beverages	  Chang	      2017-02-01	  27
-- Beverages	  Chang	      2017-03-01	  37


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee

Create --Drop
View vInventoriesByProductsByEmployees
As
SELECT Top 10000
			   c.CategoryName
			 , p.ProductName
			 , i.InventoryDate
			 , i.Count
			 , e.EmployeeFirstName + ' ' + e.EmployeeLastName as 'Employee Name'
	FROM vInventories as i 
		INNER JOIN vProducts as p
		ON i.ProductID = p.ProductID
		INNER JOIN vCategories as c
		ON p.CategoryID=c.CategoryID
		INNER JOIN vEmployees as e
		ON i.EmployeeID = e.EmployeeID
	ORDER BY i.InventoryDate, c.CategoryName, p.ProductName, [Employee Name]
;
GO

Select * From [dbo].[vInventoriesByProductsByEmployees]
GO

-- Here is an example of some rows selected from the view:
-- CategoryName	ProductName	        InventoryDate	Count	EmployeeName
-- Beverages	  Chai	              2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	              2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chartreuse verte	  2017-01-01	  69	  Steven Buchanan
-- Beverages	  C�te de Blaye	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Guaran� Fant�stica	2017-01-01	  20	  Steven Buchanan
-- Beverages	  Ipoh Coffee	        2017-01-01	  17	  Steven Buchanan
-- Beverages	  Lakkalik��ri	      2017-01-01	  57	  Steven Buchanan

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

Create --Drop
View vInventoriesForChaiAndChangByEmployees
As
SELECT Top 10000
			  c.CategoryName	
			, p.ProductName
			, i.InventoryDate
			, i.Count,e.EmployeeFirstName + ' ' + e.EmployeeLastName as 'Employee Name'
	FROM vInventories as i 
		INNER JOIN vProducts as p
		ON i.ProductID = p.ProductID
		INNER JOIN vCategories as c
		ON p.CategoryID=c.CategoryID
		INNER JOIN vEmployees as e
		ON i.EmployeeID = e.EmployeeID
	WHERE i.ProductID IN (SELECT ProductID
						FROM Products 
						WHERE ProductName='Chai' or ProductName='Chang')
	ORDER BY i.InventoryDate, c.CategoryName, p.ProductName
; 
GO

Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
GO

-- Here are the rows selected from the view:

-- CategoryName	ProductName	InventoryDate	Count	EmployeeName
-- Beverages	  Chai	      2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chai	      2017-02-01	  49	  Robert King
-- Beverages	  Chang	      2017-02-01	  27	  Robert King
-- Beverages	  Chai	      2017-03-01	  59	  Anne Dodsworth
-- Beverages	  Chang	      2017-03-01	  37	  Anne Dodsworth


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

Create --Drop
View vEmployeesByManager
As
SELECT Top 10000
				   e2.EmployeeFirstName+' '+e2.EmployeeLastName as 'Manager'
				 , e1.EmployeeFirstName+' '+e1.EmployeeLastName as 'Employee'
		FROM vEmployees as e1 INNER Join vEmployees as e2
			ON e2.EmployeeID = e1.ManagerID
		ORDER BY Manager, e1.EmployeeFirstName
;
GO

Select * From [dbo].[vEmployeesByManager]
GO

-- Here are the rows selected from the view:
-- Manager	        Employee
-- Andrew Fuller	  Andrew Fuller
-- Andrew Fuller	  Janet Leverling
-- Andrew Fuller	  Laura Callahan
-- Andrew Fuller	  Margaret Peacock
-- Andrew Fuller	  Nancy Davolio
-- Andrew Fuller	  Steven Buchanan
-- Steven Buchanan	Anne Dodsworth
-- Steven Buchanan	Michael Suyama
-- Steven Buchanan	Robert King


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

--Select Top 10000
--			c.CategoryID
--			, c.CategoryName
--			, p.ProductID
--			, p. ProductName
--			, p.UnitPrice
--			, i.InventoryID
--			, i.InventoryDate
--			, i.Count
--			, i.EmployeeID
--			, e.EmployeeFirstName + ' ' + e.EmployeeLastName as "Employee Name"
--			, m.EmployeeFirstName + ' ' + m.EmployeeLastName as "Manager Name"
--	From Inventories as i 
--			Inner Join Products as p
--			ON i.ProductID = p.ProductID
--			Inner Join Categories as c
--			On p.CategoryID = c.CategoryID
--			Inner Join Employees as e
--			ON i.EmployeeID = e.EmployeeID
--			Inner Join Employees as m
--			On e.ManagerID=m.EmployeeID
--	Order By c.CategoryName, p. ProductName,i.InventoryID, [Employee Name]


Create --Drop
View vInventoriesByProductsByCategoriesByEmployees
As
	Select Top 10000
			  c.CategoryID
			, c.CategoryName
			, p.ProductID
			, p. ProductName
			, p.UnitPrice
			, i.InventoryID
			, i.InventoryDate
			, i.Count
			, i.EmployeeID
			, e.EmployeeFirstName + ' ' + e.EmployeeLastName as "Employee Name"
			, m.EmployeeFirstName + ' ' + m.EmployeeLastName as "Manager Name"
	From vInventories as i 
			Inner Join vProducts as p
			ON i.ProductID = p.ProductID
			Inner Join vCategories as c
			On p.CategoryID = c.CategoryID
			Inner Join vEmployees as e
			ON i.EmployeeID = e.EmployeeID
			Inner Join vEmployees as m
			On e.ManagerID=m.EmployeeID
	Order By c.CategoryName, p. ProductName,i.InventoryID, [Employee Name];
GO
	Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]
GO
	--I thought we were supposed to bring in the Manager Name, so I did, but it is not included in the table below.

-- Here is an example of some rows selected from the view:
-- CategoryID	  CategoryName	ProductID	ProductName	        UnitPrice	InventoryID	InventoryDate	Count	EmployeeID	Employee
-- 1	          Beverages	    1	        Chai	              18.00	    1	          2017-01-01	  39	  5	          Steven Buchanan
-- 1	          Beverages	    1	        Chai	              18.00	    78	        2017-02-01	  49	  7	          Robert King
-- 1	          Beverages	    1	        Chai	              18.00	    155	        2017-03-01	  59	  9	          Anne Dodsworth
-- 1	          Beverages	    2	        Chang	              19.00	    2	          2017-01-01	  17	  5	          Steven Buchanan
-- 1	          Beverages	    2	        Chang	              19.00	    79	        2017-02-01	  27	  7	          Robert King
-- 1	          Beverages	    2	        Chang	              19.00	    156	        2017-03-01	  37	  9	          Anne Dodsworth
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    24	        2017-01-01	  20	  5	          Steven Buchanan
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    101	        2017-02-01	  30	  7	          Robert King
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    178	        2017-03-01	  40	  9	          Anne Dodsworth
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    34	        2017-01-01	  111	  5	          Steven Buchanan
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    111	        2017-02-01	  121	  7	          Robert King
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    188	        2017-03-01	  131	  9	          Anne Dodsworth


-- Test your Views (NOTE: You must change the names to match yours as needed!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/