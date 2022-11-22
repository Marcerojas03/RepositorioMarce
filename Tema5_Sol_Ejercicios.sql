---------------------------------------------------------------------
-- Tema 5: Optimización y rendimiento

-- Ejercicios
---------------------------------------------------------------------


-- 1. Crea un índice agrupado sobre la tabla que creamos en el tema 3
-- con la columna Id.

-- Sol:
Use BDTema3
go
Select*from Alumnos

CREATE CLUSTERED INDEX idx_ID_Alumnos
ON Alumnos (ID);


-- 2. Crea un índice no agrupado sobre la tabla que creamos en el tema 3
-- con la columna nombre. 

-- Sol:
CREATE NONCLUSTERED INDEX idx_nombre_Alumnos
ON Alumnos (Nombre);





