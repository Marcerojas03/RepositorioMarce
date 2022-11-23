USE Peritajegrupo1
go

select * from ASEGURADORA;
select * from CLIENTE;
select * from ASEGURADO;
select * from perito;
select * from Cobertura;
select * from ramo;
select * from ESTADO;
select * from SINIESTRO;
select * from SINIESTRO_COBERTURA
select * from FACTURAS
select * from LÍNEA_FACTURAS



--------------------------------------------------------------------------------------------------- 
----intento trigger para que cuando cambie el estado del siniestro a Cerrado, 
----tome la fecha de ese dia

if OBJECT_ID('dbo.fecha_Scerrado') is not null
  drop trigger dbo.fecha_Scerrado;
  go


create trigger dbo.fecha_Scerrado
    on dbo.SINIESTRO
after UPDATE
as 
begin

   IF (select IdEstado from inserted) = 6 
     begin
	   declare @fecha_cierre as date;
	   set @fecha_cierre = (select Fecha_cierre from inserted i);
	   update Fecha_cierre
	     set Fecha_cierre = date() 
		 where Fecha_cierre = @fecha_cierre;
     end
end;







------
if OBJECT_ID('dbo.sumcasper') is not null
  drop trigger dbo.sumcasper;
  go

create trigger dbo.sumcasper
    on dbo.SINIESTRO
after UPDATE

as 
begin

   IF (select IdEstado from inserted) = 3 
     begin
	   declare @perito as int;
	   set @perito = (select IdPerito from inserted i);
	   update perito 
	     set num_casos = num_casos + 1 
		 where idPerito = @perito;
     end
end;

if OBJECT_ID('dbo.rescasper') is not null
  drop trigger dbo.rescasper;
  go

create trigger dbo.rescasper
    on dbo.SINIESTRO
after UPDATE

as 
begin

   IF (select IdEstado from inserted) = 6 
     begin
	   declare @perito as int;
	   set @perito = (select IdPerito from inserted i);
	   update perito 
	     set num_casos = num_casos - 1 
		 where idPerito = @perito;
     end
end;



-----------------------------------------------------------------------------
-- creamos un indice para el dni de asegurado, el cif de clientes y cif de aseguradora

USE PERITAJEGRUPO1
go

create nonclustered index idx_dni_asegurado
on asegurado (dni);

create nonclustered index idx_cif_clientes
on cliente (cif);

create nonclustered index idx_cif_aseguradora
on aseguradora (cif);

