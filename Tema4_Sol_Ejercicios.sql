---------------------------------------------------------------------
-- Tema 4: Vistas, funciones y procedimientos

-- Ejercicios
---------------------------------------------------------------------

-- 1. Suponga el siguiente escenario: se le ha pedido que desarrolle la interfaz de la 
-- base de datos para un informe sobre la base de datos TSQL2012. La aplicaci�n necesita 
-- una vista que muestre la cantidad vendida y ventas totales para todas las ventas, 
-- por a�o, por cliente y por transportista. El usuario tambi�n desea ser capaz de filtrar 
-- los resultados por cantidad total superior e inferior. Dividiremos este ejercicio en 
-- partes para hacerlo m�s sencillo.

-- 1.a) Comience con el Sales.OrderTotalsByYear actual como se muestra en las diapositivas. 
--  Escriba la instrucci�n SELECT sin la definici�n de vista.

-- Sol:
USE TSQL2012;
GO
SELECT
 YEAR(O.orderdate) AS [A�o de venta],
 SUM(OD.qty) AS [Cantidad Vendida]
FROM Sales.Orders AS O
 JOIN Sales.OrderDetails AS OD
 ON OD.orderid = O.orderid
GROUP BY YEAR(orderdate);

-- 1.b) A�ade a la consulta anterior el importe de ventas calculado, con la f�rmula:
-- SUM(OD.qty * OD.unitprice * (1 - OD.discount))
-- Convierte esta expresi�n en NUMERIC(12, 2) y p�ngale un nombre a la columna resultante.

-- Sol:
SELECT
 YEAR(O.orderdate) AS [A�o de venta],
 SUM(OD.qty) AS [Cantidad Vendida],
 CAST(SUM(OD.qty * OD.unitprice * (1 - OD.discount))
 AS NUMERIC(12, 2)) AS val
FROM Sales.Orders AS O
 JOIN Sales.OrderDetails AS OD
 ON OD.orderid = O.orderid
GROUP BY YEAR(orderdate);


-- 1.c) Agregue las columnas para custid para devolver la identificaci�n del cliente y 
--  la identificaci�n del remitente. Tenga en cuenta que ahora debe cambiar la cl�usula 
--  GROUP BY para exponer esos dos ID.


-- Sol:
SELECT
 O.custid,
 O.shipperid,
 YEAR(O.orderdate) AS [A�o de venta],
 SUM(OD.qty) AS [Cantidad Vendida],
 CAST(SUM(OD.qty * OD.unitprice * (1 - OD.discount))
 AS NUMERIC(12, 2)) AS val
FROM Sales.Orders AS O
 JOIN Sales.OrderDetails AS OD
 ON OD.orderid = O.orderid
GROUP BY YEAR(O.orderdate), O.custid, O.shipperid;


-- 1.d) Mostrar los nombres del transportista y del cliente en los resultados
--  para el informe Por lo tanto, debe agregar JOIN a la tabla Sales.Customers 
--  y a Sales.Shippers.

SELECT
 YEAR(O.orderdate) AS [A�o de venta],
 SUM(OD.qty) AS [Cantidad Vendida],
 CAST(SUM(OD.qty * OD.unitprice * (1 - OD.discount))
 AS NUMERIC(12, 2)) AS val
FROM Sales.Orders AS O
 JOIN Sales.OrderDetails AS OD
 ON OD.orderid = O.orderid
 JOIN Sales.Customers AS C
 ON O.custid = C.custid
 JOIN Sales.Shippers AS S
 ON O.shipperid = S.shipperid
GROUP BY YEAR(O.orderdate);


-- 1.e) Agregue el nombre de la empresa del cliente (companyname) y el nombre de la 
--  empresa de env�o (companyname). Debe expandir la cl�usula GROUP BY para 
--  exponer esas columnas.


-- Sol:
SELECT
 C.companyname AS [Compa��a del cliente],
 S.companyname AS [Compa��a de env�o],
 YEAR(O.orderdate) AS [A�o de venta],
 SUM(OD.qty) AS [Cantidad Vendida],
 CAST(SUM(OD.qty * OD.unitprice * (1 - OD.discount))
 AS NUMERIC(12, 2)) AS val
FROM Sales.Orders AS O
 JOIN Sales.OrderDetails AS OD
 ON OD.orderid = O.orderid
 JOIN Sales.Customers AS C
 ON O.custid = C.custid
 JOIN Sales.Shippers AS S
 ON O.shipperid = S.shipperid
GROUP BY YEAR(O.orderdate), C.companyname, S.companyname;


-- 1.f) Convierta esto en una vista llamada Sales.OrderTotalsByYearCustShip.

--Sol:
IF OBJECT_ID (N'Sales.OrderTotalsByYearCustShip', N'V') IS NOT NULL
 DROP VIEW Sales.OrderTotalsByYearCustShip;
GO
CREATE VIEW Sales.OrderTotalsByYearCustShip
 WITH SCHEMABINDING
AS
SELECT
 C.companyname AS [Compa��a del cliente],
 S.companyname AS [Compa��a de env�o],
 YEAR(O.orderdate) AS [A�o de venta],
 SUM(OD.qty) AS [Cantidad Vendida],
 CAST(SUM(OD.qty * OD.unitprice * (1 - OD.discount))
 AS NUMERIC(12, 2)) AS val
FROM Sales.Orders AS O
 JOIN Sales.OrderDetails AS OD
 ON OD.orderid = O.orderid
 JOIN Sales.Customers AS C
 ON O.custid = C.custid
 JOIN Sales.Shippers AS S
 ON O.shipperid = S.shipperid
GROUP BY YEAR(O.orderdate), C.companyname, S.companyname;
GO
-- 2. Prueba la vista seleccionando la [Compa��a del cliente], la 
--  [Compa��a de env�o], el [A�o de venta], la [Cantidad Vendida] y el valor calculado
--  ordenado por la [Compa��a del cliente], la [Compa��a de env�o] y el [A�o de venta].

-- Sol:
SELECT [Compa��a del cliente], [Compa��a de env�o], [A�o de venta], 
	[Cantidad Vendida], val
FROM Sales.OrderTotalsByYearCustShip
ORDER BY [Compa��a del cliente], [Compa��a de env�o], [A�o de venta];


-- 3. Una funci�n que recibe el identificador de proveedor ( @supplierid ) y 
--  un n�mero ( @n ) y devuleve los n productos m�s baratos de dicho proveedor 

-- Sol:
IF OBJECT_ID(N'Production.GetTopProducts', N'IF') IS NOT NULL 
	DROP FUNCTION Production.GetTopProducts;
GO
CREATE FUNCTION Production.GetTopProducts(
@supplierid AS INT, @n AS BIGINT
) 
RETURNS TABLE
AS

RETURN
  SELECT productid, productname, unitprice
  FROM Production.Products
  WHERE supplierid = @supplierid
  ORDER BY unitprice, productid
  OFFSET 0 ROWS FETCH FIRST @n ROWS ONLY;
GO

-- 4. Prueba la funci�n anterior con los 2 productos del proveedor 1

-- Sol:
SELECT * FROM Production.GetTopProducts(1, 2) AS P;




-- 5. Hacer procedimiento que calcule el n�mero de pedidos
--  por clientes de un pa�s determinado.

-- Sol:
USE TSQL2012;
GO

IF OBJECT_ID('Sales.OrdersPerCountry', 'P') IS NOT NULL
DROP PROC Sales.OrdersPerCountry;
GO

CREATE PROC Sales.OrdersPerCountry
@country AS VARCHAR(max)
AS
BEGIN

SELECT C.custid, COUNT(*) AS numPedidos
FROM Sales.Customers AS C
  INNER JOIN Sales.Orders AS O
    ON C.custid = O.custid
WHERE C.country = @country
GROUP BY C.custid;

RETURN;
END
GO

-- 6. Probar el procedimiento devolviendo los n�meros de pedidos por clientes 
--  de Espa�a y Mexico

-- Sol: 
execute Sales.OrdersPerCountry 'Spain'
execute Sales.OrdersPerCountry 'Mexico'


-- 7. Hacer un trigguer a la tabla que crearon en el tema 3, que devuelva la cantidad
--  de registros insertados y eliminados.


-- Sol:
use BDTema3;IF OBJECT_ID('After_TriggerAlumnos') IS NOT NULL
 DROP TRIGGER After_TriggerAlumnos;
GO
CREATE TRIGGER After_TriggerAlumnos
ON Alumnos
AFTER DELETE, INSERT, UPDATE
AS
BEGIN
 IF @@ROWCOUNT = 0 RETURN;
 -- SET NOCOUNT ON;
 SELECT COUNT(*) AS InsertedCount FROM Inserted;
 SELECT COUNT(*) AS DeletedCount FROM Deleted; --SELECT COUNT(*) AS DeletedCount FROM Updated; END;-- 8. Pruebe el funcionamiento del trigger anterior, insertando y eliminando --  un registro-- Sol:INSERT INTO Alumnos
VALUES (5,'alumno5',22,'F',123406789);
select*from Alumnos

-- 9. Crear una copia de la tabla anterior y crear un trigger que cuando 
-- se intente eliminar un registro en una tabla, y lo inserte en otra

-- Sol:
use BDTema3; CREATE TABLE Alumnos_matriculados (
ID integer,
Nombre varchar(max),
Edad tinyint ,
G�nero char(1),
Tel�fono integer,
);IF OBJECT_ID('INSTEAD_TriggerAlumnos') IS NOT NULL
 DROP TRIGGER INSTEAD_TriggerAlumnos;
GO
CREATE TRIGGER INSTEAD_TriggerAlumnos
ON Alumnos
INSTEAD OF  DELETE
AS
BEGIN
 IF @@ROWCOUNT = 0 RETURN;

 INSERT Alumnos_matriculados (ID,Nombre,Edad,[G�nero],[Tel�fono])
 SELECT ID,Nombre,Edad,[G�nero],[Tel�fono] FROM deleted; END;-- 10. Pruebe el funcionamiento del trigger anterior.-- Sol:DELETE FROM Alumnos
WHERE ID = 2;select*from Alumnosselect*from Alumnos_matriculados