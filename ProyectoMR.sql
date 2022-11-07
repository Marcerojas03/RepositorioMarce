--Crear Base de datos
create database ProyectoMR
go

USE ProyectoMR
go



--Crear tabla Clientes:

IF OBJECT_ID (N'Clientes') is not null drop table Clientes 
go

CREATE TABLE Clientes 
(
IdDNI         NVARCHAR (9)      NOT NULL,
Nombre        NVARCHAR (40)     NOT NULL, 
Apellido      NVARCHAR (40)     NOT NULL,
Mail          NVARCHAR (40)     NOT NULL,
Telefono      nvarchar (9)      NOT NULL,
);
go


alter table Clientes
add constraint PK_DNI primary key (DNI)
go



insert into Clientes
select * from Clientes$



--Insertar datos en las tablas.

INSERT INTO Clientes (IdDNI, Nombre, Apellido, Mail, Telefono) 
VALUES ('60054385V', 'Ali', 'Moussa', 'ali-moussa92@hotmail.com', '625838241'
);
INSERT INTO Clientes (IdDNI, Nombre, Apellido, Mail, Telefono)
VALUES ('50752268P',	'Almudena',  'Sainz', 'alsainzcavada@gmail.com', '651727908'
);
INSERT INTO Clientes (IdDNI, Nombre, Apellido, Mail, Telefono)
VALUES ('05398473M', 'Ana', 'Mateo Benito', '69colon38@gmail.com', '687883525'
);
INSERT INTO Clientes (IdDNI, Nombre, Apellido, Mail, Telefono)
VALUES ('04589158Z', 'Andrés', 'Dávila', 'tableros@marinodelafuente.es', '602001075'
);
INSERT INTO Clientes (IdDNI, Nombre, Apellido, Mail, Telefono)
VALUES ('02638670H',	'Carmen',	'Fernandez',	'cfernandezvallina@gmail.com',	'622158754'
);
INSERT INTO Clientes (IdDNI, Nombre, Apellido, Mail, Telefono)
VALUES ('51864609T',	'Andrés', 	'Quintana',	'afquintana.rivera@gmail.com',	'631471971'
);
INSERT INTO Clientes (IdDNI, Nombre, Apellido, Mail, Telefono)
VALUES ('X0512823S',	'Antonio', 	'Puente Badía',	'puentebadia.arq@gmail.com',	'657462137'
);
INSERT INTO Clientes (IdDNI, Nombre, Apellido, Mail, Telefono)
VALUES ('51401086L',	'Blanca',	'Magro',	'blancalean@gmail.com',	'636391900'
);
INSERT INTO Clientes (IdDNI, Nombre, Apellido, Mail, Telefono)
VALUES ('33518629Q',	'Carlos',	'Buenapozada Perez',	'carlos_buenaposada@hotmail.com',	'637142656'
);
INSERT INTO Clientes (IdDNI, Nombre, Apellido, Mail, Telefono)
VALUES ('00392591G',	'Carlota', 	'Sainz Cotera',	'carlotasainzcotera@gmail.com',	'670223290'
);
go



--Crear tabla Productos:

IF OBJECT_ID (N'Productos') is not null drop table Productos 
go

Create table Productos 
(
SKU           nvarchar (20)     NOT NULL,
categoria     nvarchar (20)     NOT NULL,
NIF           int               NOT NULL,
Tipo          nvarchar (20)     NULL,
Descripción   nvarchar (40)     NULL,
Peso          int               NULL,
Longitud      int               NULL, 
Ancho         int               NULL,
Altura        int               NULL,
Precio        money             NULL,

PRIMARY KEY(SKU),
  FOREIGN KEY(IDcategoria),
  FOREIGN KEY (NIF),
);
	

alter table dbo.Productos
add constraint PK_SKU primary key ([SKU])
go

alter table dbo.Productos
add constraint FK_Categoría foreign key ([Categoría])
go


alter table dbo.Productos
add constraint FK_NIF foreign key (NIF)




select * from productos



Create table Compras 
(
Idcompra      int IDENTITY(1.1) NOT NULL,
IdDNI         int               NOT NULL,
SKU           int               NOT NULL,
fecha         DATETIME          NOT NULL,
cantidad      int               NOT NULL,
Importe       money             NOT NULL,

PRIMARY KEY(Idcompra),
);





Create table Categoria 
(
IdCategoria   int           NOT NULL,
Descripcion nvarchar (40)   NOT NULL
);



Create table Proveedores 
(
NIF           int           NOT NULL,
Nombre        nvarchar (40) NOT NULL,
Dirección     nvarchar (40) NOT NULL,
Ciudad        nvarchar (10) NOT NULL,
ProdServ nvarchar (40)      NOT NULL,
Descripción nvarchar (50)   NOT NULL,
Contrato nvarchar (2)       NOT NULL,
CONSTRAINT PK_NIF PRIMARY KEY(NIF)
);



create table Suministros 
(
Idcompra int,
SKU int,
NIF int,
fechaCompra DATETIME,
Categoria nvarchar (20),
Cantidad int,
total money
);


--se insertaron tablas en excel 
select * from Categorias$
select * from Clientes$
select * from Compras$
select * from Prductos$
select * from Prductos$COLUMNAS_PARA_PRODUCTOS
select * from Proveedores$
select * from Suministros$



--crear llaves en las tablas

--PRIMARIAS
alter table Categorías
add constraint PK_Categoría primary key (Categoría)
go


alter table Clientes
add constraint PK_DNI primary key (DNI)
go


alter table dbo.Productos
add constraint PK_SKU primary key ([SKU])
go


alter table dbo.Compras
add constraint PK_id primary key (ID)
go


alter table dbo.Proveedores
add constraint PK_Proveedor primary key (NIF)
go

alter table dbo.Suministros
add constraint PK_Idsum primary key (Idsum)
go




--SECUNDARIAS
alter table dbo.Compras
add constraint FK_DNI FOREIGN key (DNI)
references dbo.Clientes (DNI)
go


alter table dbo.Compras
add constraint FK_sku2 FOREIGN key (sku)
references dbo.Productos (SKU)
go



alter table dbo.Productos
add constraint FK_Categoría FOREIGN key (Categoría)
references dbo.Categorías (Categoría)
go

alter table dbo.Productos
add constraint FK_NIF FOREIGN key (NIF)
references dbo.Proveedores (NIF)
go

alter table dbo.Suministros
add constraint FK_sku FOREIGN key (sku)
references dbo.Productos (sku)
go

alter table dbo.Suministros
add constraint FK_nifp FOREIGN key (NIF)
references dbo.Proveedores (NIF)
go



--CONSULTAS VARIAS:
--VER LOS 5 ELEMENTOS QUE MAS SE COMPRARON ORDENADOS POR CANTIDAD

SELECT TOP 5 Idcompra, CANTIDAD, IMPORTE 
FROM dbo.Compras
ORDER BY CANTIDAD DESC



--VER LAS COMPRAS DE SUMINISTROS ENTRE DEL DIA 24-10-2022 AL 26-10-2022 

SELECT Idsum, sku, categoria, cantidad, total, [fecha de compra]
FROM Suministros
WHERE [fecha de compra] between '20221024' AND '20221026'
ORDER BY idSum






--actualizar registros de la tabla Suministros$

select * from Suministros$

UPDATE Suministros$
SET Idsum='2'
WHERE  Idsum='30'

UPDATE Suministros$
SET Idsum='3'
WHERE  Idsum='31'

UPDATE Suministros$
SET Idsum='4'
WHERE  Idsum='32'

UPDATE Suministros$
SET Idsum='5'
WHERE  Idsum='33'

UPDATE Suministros$
SET Idsum='6'
WHERE  Idsum='34'

UPDATE Suministros$
SET Idsum='7'
WHERE  Idsum='35'

UPDATE Suministros$
SET Idsum='8'
WHERE  Idsum='36'


--crear un procedimiento 
--ver los clientes que mas compraron (opcional por fecha)
select * from dbo.Compras


SELECT TOP 5 ID, CANTIDAD, IMPORTE 
FROM COMPRAS
ORDER BY CANTIDAD DESC





--crear un procedimiento
--VER LAS COMPRAS DE SUMINISTROS ENTRE DEL DIA 24-10-2022 AL 26-10-2022 
SELECT Idsum, sku, categoria, cantidad, total, [fecha de compra] 
FROM Suministros
WHERE [fecha de compra] between '20221024' AND '20221026'
ORDER BY idSum



USE ProyectoMR;
GO

IF OBJECT_ID('Suministros$', 'P') IS NOT NULL
DROP PROC Suministros$,ComprasporFecha;
GO

create proc ComprasporFecha
@fecha I as varchar (max)
@fecha F
as
begin

SELECT [fecha de compra],COUNT(*) AS cantidadtotal 
FROM Suministros$
WHERE [fecha de compra] between '20221024' AND '20221026'
group by [fecha de compra]
ORDER BY [fecha de compra]

RETURN;
END
GO



--Insertar un nuevo cliente si no tiene compras anteriores
select * from clientes
select * from Compras


Use ProyectoMR
go

if OBJECT_ID ('Compras.IDcero', Idcero) is not null 
drop proc Compras.Idcero;
go

create proc Compras.Idcero
@dni as nvarchar(max)

as
begin

INSERT INTO Clientes (DNI, Nombre, Apellido, [E-mail], Telefono) 
VALUES ('Y6221149P', 'Marcela', 'Rojas', 'marcerojas03@gmail.com', '622744124')

where dni = @dni
group by 

return

end 
go


Select cl.dni, cl.nombre, cl.apellido, co.id
inner join dbo.Clientes as Cl
FROM dbo.Compras AS Co
  ON cl.dni = co.dni



-- probar el procedimiento
execute Compras.Idcero 'Y6221149P'

