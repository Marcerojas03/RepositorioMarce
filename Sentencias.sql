---------------------------------------------------------------------
-- Filtering Date and Time Data
---------------------------------------------------------------------

-- language-dependent literal
SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE orderdate = '02/12/07';

-- language-neutral literal - yyyymmdd
SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE orderdate = '20070212';

-- not SARG
SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE YEAR(orderdate) = 2007 AND MONTH(orderdate) = 2;

-- SARG
SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE orderdate >= '20070201' AND orderdate < '20070301';

---------------------------------------------------------------------
-- Filtering Data with TOP and OFFSET-FETCH
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Filtering Data with TOP
---------------------------------------------------------------------

-- return the three most recent orders
SELECT TOP (3) orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;

-- can use percent
SELECT TOP (1) PERCENT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;
GO

-- can use expression, like parameter or variable, as input
DECLARE @n AS BIGINT = 5;

SELECT TOP (@n) orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;
GO

-- no ORDER BY, ordering is arbitrary
SELECT TOP (3) orderid, orderdate, custid, empid
FROM Sales.Orders;

-- be explicit about arbitrary ordering
SELECT TOP (3) orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY (SELECT NULL);

-- non-deterministic ordering even with ORDER BY since ordering isn't unique
SELECT TOP (3) orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;

-- return all ties
SELECT TOP (3) WITH TIES orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;

-- break ties
SELECT TOP (3) orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC, orderid DESC;

---------------------------------------------------------------------
-- Filtering Data with OFFSET-FETCH
---------------------------------------------------------------------

-- skip 50 rows, fetch next 25 rows
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC, orderid DESC
OFFSET 50 ROWS FETCH NEXT 25 ROWS ONLY;

-- fetch first 25 rows
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC, orderid DESC
OFFSET 0 ROWS FETCH FIRST 25 ROWS ONLY;

-- skip 50 rows, return all the rest
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC, orderid DESC
OFFSET 50 ROWS;

-- ORDER BY is mandatory; return some 3 rows
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY (SELECT NULL)
OFFSET 0 ROWS FETCH FIRST 3 ROWS ONLY;
GO

-- can use expressions as input
DECLARE @pagesize AS BIGINT = 25, @pagenum AS BIGINT = 3;

SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC, orderid DESC
OFFSET (@pagenum - 1) * @pagesize ROWS FETCH NEXT @pagesize ROWS ONLY;
GO

---------------------------------------------------------------------
-- Using Subqueries
---------------------------------------------------------------------


-- Self-Contained Subqueries

-- scalar subqueries
-- products with minimum price
SELECT productid, productname, unitprice
FROM Production.Products
WHERE unitprice =
  (SELECT MIN(unitprice)
   FROM Production.Products);
   
-- multi-valued subqieries
-- products supplied by suppliers from Japan
SELECT productid, productname, unitprice
FROM Production.Products
WHERE supplierid IN
  (SELECT supplierid
   FROM Production.Suppliers
   WHERE country = N'Japan');

-- Correlated Subqueries

-- products with minimum unitprice per category
SELECT categoryid, productid, productname, unitprice
FROM Production.Products AS P1
WHERE unitprice =
  (SELECT MIN(unitprice)
   FROM Production.Products AS P2
   WHERE P2.categoryid = P1.categoryid);

-- customers who placed an order on February 12, 2007
SELECT custid, companyname
FROM Sales.Customers AS C
WHERE EXISTS
  (SELECT *
   FROM Sales.Orders AS O
   WHERE O.custid = C.custid
     AND O.orderdate = '20070212');

-- customers who did not place an order on February 12, 2007
SELECT custid, companyname
FROM Sales.Customers AS C
WHERE NOT EXISTS
  (SELECT *
   FROM Sales.Orders AS O
   WHERE O.custid = C.custid
     AND O.orderdate = '20070212');

---------------------------------------------------------------------
-- Table Expressions
---------------------------------------------------------------------

-- Derived Tables

-- row numbers for products
-- partitioned by categoryid, ordered by unitprice, productid
SELECT
  ROW_NUMBER() OVER(PARTITION BY categoryid
                    ORDER BY unitprice, productid) AS rownum,
  categoryid, productid, productname, unitprice
FROM Production.Products;

-- two products with lowest prices per category
SELECT categoryid, productid, productname, unitprice
FROM (SELECT
        ROW_NUMBER() OVER(PARTITION BY categoryid
                          ORDER BY unitprice, productid) AS rownum,
        categoryid, productid, productname, unitprice
      FROM Production.Products) AS D
WHERE rownum <= 2;

-- CTEs

-- two products with lowest prices per category
WITH C AS
(
  SELECT
    ROW_NUMBER() OVER(PARTITION BY categoryid
                      ORDER BY unitprice, productid) AS rownum,
    categoryid, productid, productname, unitprice
  FROM Production.Products
)
SELECT categoryid, productid, productname, unitprice
FROM C
WHERE rownum <= 2;

-- Recursive CTE
-- management chain leading to given employee
WITH EmpsCTE AS
(
  SELECT empid, mgrid, firstname, lastname, 0 AS distance
  FROM HR.Employees
  WHERE empid = 9

  UNION ALL

  SELECT M.empid, M.mgrid, M.firstname, M.lastname, S.distance + 1 AS distance
  FROM EmpsCTE AS S
    JOIN HR.Employees AS M
      ON S.mgrid = M.empid
)
SELECT empid, mgrid, firstname, lastname, distance
FROM EmpsCTE;
GO

-- Views

-- view representing ranked products per category by unitprice
IF OBJECT_ID(N'Sales.RankedProducts', N'V') IS NOT NULL DROP VIEW Sales.RankedProducts;
GO
CREATE VIEW Sales.RankedProducts
AS

SELECT
  ROW_NUMBER() OVER(PARTITION BY categoryid
                    ORDER BY unitprice, productid) AS rownum,
  categoryid, productid, productname, unitprice
FROM Production.Products;
GO

SELECT categoryid, productid, productname, unitprice
FROM Sales.RankedProducts
WHERE rownum <= 2;

-- Inline Table-Valued Functions

-- management chain leading to given employee
IF OBJECT_ID(N'HR.GetManagers', N'IF') IS NOT NULL DROP FUNCTION HR.GetManagers;
GO
CREATE FUNCTION HR.GetManagers(@empid AS INT) RETURNS TABLE
AS

RETURN
  WITH EmpsCTE AS
  (
    SELECT empid, mgrid, firstname, lastname, 0 AS distance
    FROM HR.Employees
    WHERE empid = @empid

    UNION ALL

    SELECT M.empid, M.mgrid, M.firstname, M.lastname, S.distance + 1 AS distance
    FROM EmpsCTE AS S
      JOIN HR.Employees AS M
        ON S.mgrid = M.empid
  )
  SELECT empid, mgrid, firstname, lastname, distance
  FROM EmpsCTE;
GO

SELECT *
FROM HR.GetManagers(8) AS M;


---------------------------------------------------------------------
-- UNION and UNION ALL
---------------------------------------------------------------------

-- locations that are employee locations or customer locations or both
SELECT country, region, city
FROM HR.Employees

UNION

SELECT country, region, city
FROM Sales.Customers;

-- with UNION ALL duplicates are not discarded
SELECT country, region, city
FROM HR.Employees

UNION ALL

SELECT country, region, city
FROM Sales.Customers;

---------------------------------------------------------------------
-- INTERSECT
---------------------------------------------------------------------

-- locations that are both employee and customer locations
SELECT country, region, city
FROM HR.Employees

INTERSECT

SELECT country, region, city
FROM Sales.Customers;

---------------------------------------------------------------------
-- EXCEPT
---------------------------------------------------------------------

-- locations that are employee locations but not customer locations
SELECT country, region, city
FROM HR.Employees

EXCEPT

SELECT country, region, city
FROM Sales.Customers;

-- cleanup
DELETE FROM Production.Suppliers WHERE supplierid > 29;
IF OBJECT_ID(N'Sales.RankedProducts', N'V') IS NOT NULL DROP VIEW Sales.RankedProducts;
IF OBJECT_ID(N'HR.GetManagers', N'IF') IS NOT NULL DROP FUNCTION HR.GetManagers;

---------------------------------------------------------------------
-- TK 70-461 - Chapter 05 - Grouping and Windowing 
-- Code
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Lesson 01 - Writing Grouped Queries
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Working With a Single Grouping Set
---------------------------------------------------------------------

-- grouped query without GROUP BY clause
USE TSQL2012;

SELECT COUNT(*) AS numorders
FROM Sales.Orders;

-- grouped query with GROUP BY clause
SELECT shipperid, COUNT(*) AS numorders
FROM Sales.Orders
GROUP BY shipperid;

-- grouping set with multiple elements
SELECT shipperid, YEAR(shippeddate) AS shippedyear,
   COUNT(*) AS numorders
FROM Sales.Orders
GROUP BY shipperid, YEAR(shippeddate);

-- filtering groups
SELECT shipperid, YEAR(shippeddate) AS shippedyear,
   COUNT(*) AS numorders
FROM Sales.Orders
WHERE shippeddate IS NOT NULL
GROUP BY shipperid, YEAR(shippeddate)
HAVING COUNT(*) < 100;

-- general aggregate functions ignore NULLs """"(las funciones de agregacion no tienen en cuenta
-- los nulos)""""
SELECT shipperid,
  COUNT(*) AS numorders,
  COUNT(shippeddate) AS shippedorders,
  MIN(shippeddate) AS firstshipdate,
  MAX(shippeddate) AS lastshipdate,
  SUM(val) AS totalvalue
FROM Sales.OrderValues
GROUP BY shipperid;

-- aggregating distinct cases
SELECT shipperid, COUNT(shippeddate), count(distinct shippeddate) AS numshippingdates
FROM Sales.Orders
GROUP BY shipperid;
GO

-- grouped query cannot refer to detail elements after grouping
SELECT S.shipperid, S.companyname, COUNT(*) AS numorders
FROM Sales.Shippers AS S
  JOIN Sales.Orders AS O
    ON S.shipperid = O.shipperid
GROUP BY S.shipperid, s.companyname;
GO

-- solution 1: add column to grouping set
SELECT S.shipperid, S.companyname,
  COUNT(*) AS numorders
FROM Sales.Shippers AS S
  INNER JOIN Sales.Orders AS O
    ON S.shipperid = O.shipperid
GROUP BY S.shipperid, S.companyname;

-- solution 2: apply an aggregate to the column
SELECT S.shipperid,
  MAX(S.companyname) AS companyname,
  COUNT(*) AS numorders
FROM Sales.Shippers AS S
  INNER JOIN Sales.Orders AS O
    ON S.shipperid = O.shipperid
GROUP BY S.shipperid;

-- solution 3: join after aggregating
WITH C AS
(
  SELECT shipperid, COUNT(*) AS numorders
  FROM Sales.Orders
  GROUP BY shipperid
)
SELECT S.shipperid, S.companyname, numorders
FROM Sales.Shippers AS S
  INNER JOIN C
    ON S.shipperid = C.shipperid;

---------------------------------------------------------------------
-- Working With Multiple Grouping Sets
---------------------------------------------------------------------

-- using the GROUPING SETS clause
SELECT shipperid, YEAR(shippeddate) AS shipyear, custid, COUNT(*) AS numorders
FROM Sales.Orders
WHERE shippeddate IS NOT NULL -- exclude unshipped orders
GROUP BY GROUPING SETS
(
  ( shipperid, YEAR(shippeddate) ),
  ( shipperid                    ),
  ( YEAR(shippeddate)            ),
  ( custid                       )
);

-- using the CUBE clause (enseña todas agrupaciones que puede hacer con las dos clausulas que le ponemos)
SELECT shipperid, YEAR(shippeddate) AS shipyear, COUNT(*) AS numorders
FROM Sales.Orders
-- where shippeddate is not null
GROUP BY CUBE( shipperid, YEAR(shippeddate) );
--(no es muy conveniente)



SELECT shipperid, YEAR(shippeddate) AS shipyear, COUNT(*) AS numorders
FROM Sales.Orders
where shippeddate is not null
GROUP BY CUBE( shipperid, YEAR(shippeddate) );




-- using the ROLLUP clause (agrupa no todos con todos) no es muy claro
SELECT shipcountry, shipregion, shipcity, COUNT(*) AS numorders
FROM Sales.Orders
GROUP BY ROLLUP( shipcountry, shipregion, shipcity );


---------------------------------------------------------------------
-- Lesson 02 - Pivoting and Unpivoting Data
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Pivoting Data (transponer filas o columnas)
---------------------------------------------------------------------

-- show customer IDs on rows, shipper IDs on columns, total freight in intersection
-- Note: grouping element is determined by elimination (shipperid is spreding element, freight is aggregation element, so custid is grouping)
WITH PivotData AS
(
  SELECT
    custid   , -- grouping column
    shipperid, -- spreading column
    freight    -- aggregation column
  FROM Sales.Orders
)
SELECT custid, [1], [2], [3]
FROM PivotData
  PIVOT(SUM(freight) FOR shipperid IN ([1],[2],[3]) ) AS P;


--otra combinacion = para cada cliente y empleado
WITH PivotData AS
(
  SELECT
    custid   , -- grouping column
    empid,
	shipperid, -- spreading column
    freight    -- aggregation column
  FROM Sales.Orders
)
SELECT custid, empid, [1], [2], [3]
FROM PivotData
  PIVOT(SUM(freight) FOR shipperid IN ([1],[2],[3]) ) AS P;




-- when applying PIVOT to Orders table direclty get a result row for each order
SELECT custid, [1], [2], [3]
FROM Sales.Orders
  PIVOT(SUM(freight) FOR shipperid IN ([1],[2],[3]) ) AS P;

---------------------------------------------------------------------
-- Unpivoting Data (la misma operacion pero en sentido contrario al pivote)
---------------------------------------------------------------------

-- sample data for UNPIVOT example
USE TSQL2012;
IF OBJECT_ID(N'Sales.FreightTotals', N'U') IS NOT NULL DROP TABLE Sales.FreightTotals;
GO

WITH PivotData AS
(
  SELECT
    custid   , -- grouping column
    shipperid, -- spreading column
    freight    -- aggregation column
  FROM Sales.Orders
)
SELECT *
INTO Sales.FreightTotals
FROM PivotData
  PIVOT( SUM(freight) FOR shipperid IN ([1],[2],[3]) ) AS P;

SELECT * FROM Sales.FreightTotals;

-- unpivot data
SELECT custid, shipperid, freight
FROM Sales.FreightTotals
  UNPIVOT( freight FOR shipperid IN([1],[2],[3]) ) AS U;

-- cleanup
IF OBJECT_ID(N'Sales.FreightTotals', N'U') IS NOT NULL DROP TABLE Sales.FreightTotals;

---------------------------------------------------------------------
-- Lesson 03 - Using Window Functions
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Window Aggregate Functions (funciones de ventana) 
---------------------------------------------------------------------

-- partitioning
select * from Sales.OrderValues

-- returning detail as well as aggregates 
-- para cada pedido el total que le he vendido) hace una particion para
-- cada cliente por eso muestra en las columnas custtotal el total 
-- de lo que vendio el cliente 1
SELECT custid, orderid, 
  val,
  SUM(val) OVER(PARTITION BY custid) AS custtotal,
  SUM(val) OVER() AS grandtotal
FROM Sales.OrderValues;


-- where custid=1;

-- computing percents of detail out of aggregates
SELECT custid, orderid, 
  val,
  CAST(100.0 * val / SUM(val) OVER(PARTITION BY custid) AS NUMERIC(5, 2)) AS pctcust,
  CAST(100.0 * val / SUM(val) OVER()                    AS NUMERIC(5, 2)) AS pcttotal
FROM Sales.OrderValues;


-- framing (parecido a la particion desde hasta) 

-- computing running total
SELECT custid, orderid, orderdate, val,
  SUM(val) OVER(PARTITION BY custid
                ORDER BY orderdate, orderid
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW) AS runningtotal
FROM Sales.OrderValues;




-- filter running totals that are less than 1000.00
WITH RunningTotals AS
(
  SELECT custid, orderid, orderdate, val,
    SUM(val) OVER(PARTITION BY custid
                  ORDER BY orderdate, orderid
                  ROWS BETWEEN UNBOUNDED PRECEDING
                           AND CURRENT ROW) AS runningtotal
  FROM Sales.OrderValues
)
SELECT *
FROM RunningTotals
WHERE runningtotal < 1000.00;

---------------------------------------------------------------------
-- Window Ranking Functions
---------------------------------------------------------------------
-- Pedido 10883 y 10815 est�n empatados, si necesitamos rownum deterministra, 
--incluir orderid in order by clauses
-- """" el mejor cliente"""

SELECT custid, orderid, val,
  ROW_NUMBER() OVER(ORDER BY val) AS rownum,
  RANK()       OVER(ORDER BY val) AS rnk,
  DENSE_RANK() OVER(ORDER BY val) AS densernk,
  NTILE(10)   OVER(ORDER BY val) AS ntile10 --10 buckets (es como el percentil pero de a 10)
FROM Sales.OrderValues
-- where orderid = 11057
-- order by orderid;

---------------------------------------------------------------------
-- Window Offset Functions
---------------------------------------------------------------------
-- �nicamente calculamos en base a una fila y no a un conjunto.

-- LAG and LEAD retrieving values from previous and next rows
-- """ la comumna prev_val muestra el valor anterior
--first_value--- el primero de todos los valores) 

SELECT custid, orderid, orderdate, val,
  LAG(val)  OVER(PARTITION BY custid
                 ORDER BY orderdate, orderid) AS prev_val,
  LEAD(val) OVER(PARTITION BY custid
                 ORDER BY orderdate, orderid) AS next_val,
  FIRST_VALUE(val) OVER(PARTITION BY custid
                 ORDER BY orderdate, orderid) AS first_val,
  LAST_VALUE(val) OVER(PARTITION BY custid
                 ORDER BY orderdate, orderid) AS last_val
FROM Sales.OrderValues;

-- Tres pedidos anteriores
-- LAG(val, 3)  OVER(PARTITION BY custid ORDER BY orderdate, orderid) AS prev_val, 

-- Tres pedidos anteriores con valores 0 para los NULLs
-- LAG(val, 3, 0)  OVER(PARTITION BY custid ORDER BY orderdate, orderid) AS prev_val,

-- FIRST_VALUE and LAST_VALUE retrieving values from first and last rows in frame
SELECT custid, orderid, orderdate, val,
  FIRST_VALUE(val)  OVER(PARTITION BY custid
                         ORDER BY orderdate, orderid
                         ROWS BETWEEN UNBOUNDED PRECEDING
                                  AND CURRENT ROW) AS first_val,
  LAST_VALUE(val) OVER(PARTITION BY custid
                       ORDER BY orderdate, orderid
                       ROWS BETWEEN CURRENT ROW
                                AND UNBOUNDED FOLLOWING) AS last_val
FROM Sales.OrderValues;