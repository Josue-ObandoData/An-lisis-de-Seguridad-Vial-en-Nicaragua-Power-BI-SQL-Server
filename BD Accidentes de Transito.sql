Create Database AccidentesDeTransitoNicaragua2026;
go

Use AccidentesDeTransitoNicaragua2026;
go

--Verificar tipo de datos de las tablas
EXEC sp_help '[dbo].[Departamentos_Destacados]';
EXEC sp_help '[dbo].[Fecha]';
EXEC sp_help '[dbo].[Regulación_de_Tráfico]';
EXEC sp_help '[dbo].[Reporte_semanal]';
EXEC sp_help '[dbo].[Tipo_de_Vehiculos]';


--Crear copias de tablas para limpiar datos

----------------------Tabla Reporte Semanal----------------------
select * into Reporte_semanal_clean 
from Reporte_semanal;

select * from Reporte_semanal_clean

ALTER TABLE Reporte_semanal_clean
ALTER COLUMN Accidentes INT;

ALTER TABLE Reporte_semanal_clean
ALTER COLUMN Lesionados INT;

EXEC sp_help 'Reporte_semanal_clean';

Delete from Reporte_semanal_clean
where Semana = '2026-W11';


-------------------------Tabla Fecha-------------------------
select * into Fecha_clean 
from Fecha;

select * from Fecha_clean

ALTER TABLE Fecha_clean
ALTER COLUMN Año INT

EXEC sp_help 'Fecha_clean';

-------------------------Tabla Regulación de Tráfico--------------------
select * into Regulación_de_Tráfico_clean
from Regulación_de_Tráfico

select * from Regulación_de_Tráfico_clean

ALTER TABLE Regulación_de_Tráfico_clean
ALTER COLUMN [Vehiculos Requisados] INT

ALTER TABLE Regulación_de_Tráfico_clean
ALTER COLUMN [Pruebas de Alcoholemia] INT

ALTER TABLE Regulación_de_Tráfico_clean
ALTER COLUMN [Ciudadanos Detenidos Sin Licencia] INT

ALTER TABLE Regulación_de_Tráfico_clean
ALTER COLUMN [Detenidos por estado de Ebriedad] INT

ALTER TABLE Regulación_de_Tráfico_clean
ALTER COLUMN [Licencias Suspendidas] INT


EXEC sp_help 'Regulación_de_Tráfico_clean';

Delete from Regulación_de_Tráfico_clean
where Semana = '2026-W11' 
Delete from Regulación_de_Tráfico_clean
where Semana = '2026-W13'

---------------------------Tabla Departamentos Destacados------------------------
Select * into Departamentos_Destacados_clean
from Departamentos_Destacados

select * from Departamentos_Destacados_clean

ALTER TABLE Departamentos_Destacados_clean
ALTER COLUMN Accidentes INT

EXEC sp_help 'Departamentos_Destacados_clean';

Delete from Departamentos_Destacados_clean
where Semana = '2026-W11' 
Delete from Departamentos_Destacados_clean
where Semana = '2026-W13' 

-----------------------Tabla Tipo de Vehiculos-----------------------
Select * into Tipo_de_Vehiculos_clean
from Tipo_de_Vehiculos

select * from Tipo_de_Vehiculos_clean

ALTER TABLE Tipo_de_Vehiculos_clean
ALTER COLUMN Accidentes INT

EXEC sp_help 'Tipo_de_Vehiculos_clean';

Delete from Tipo_de_Vehiculos_clean
where Semana = '2026-W11'
Delete from Tipo_de_Vehiculos_clean
where Semana = '2026-W13'

------------------Consultas para obtener insights---------------
--Total Accidentes y lesionados--
Select
SUM(Accidentes) AS Total_Accidentes,
SUM(Lesionados) AS Total_Lesionados
from Reporte_semanal_clean;
--Promedio de lesionados por accidente--
Select 
SUM(Accidentes) AS Total_Accidentes,
SUM(Lesionados) AS Total_Lesionados,
CAST(SUM(Lesionados) * 100.0 / NULLIF(SUM(Accidentes),0) AS decimal(10,2)) AS Promedio_lesionados_por_accidentes
from Reporte_semanal_clean
--Departamentos con mas accidentes--
Select [Departamento], SUM(Accidentes) AS Total_Accidentes
from Departamentos_Destacados_clean
Group by [Departamento]
Order by Total_Accidentes DESC;
--Porcentaje de accidentes de managua del total--
Select [Departamento], SUM(Accidentes) AS Total_Accidentes,
CAST(
	SUM(Accidentes) * 100.00 /
	(
		Select SUM(Accidentes)
		From [dbo].[Departamentos_Destacados_clean]
	)
	AS decimal(10,2)
) AS Porcentaje_Nacional
From [dbo].[Departamentos_Destacados_clean]
Group by [Departamento]
Order by Total_Accidentes DESC;
--Tipo de vehiculo que generan mas accidentes--
Select [Tipo de Vehiculo], SUM(Accidentes) AS Total_Accidentes,
CAST(
	SUM(Accidentes) * 100.0 / 
	(
	Select SUM(Accidentes)
	From [dbo].[Tipo_de_Vehiculos_clean]
	)
	AS decimal(10,2)
) AS Porcentaje_Nacional
From [dbo].[Tipo_de_Vehiculos_clean]
Group by [Tipo de Vehiculo]
Order by Total_Accidentes DESC;
--Accidentes vs detenidos por estado de ebriedad--
Select
rs.[Semana],
rs.[Accidentes],
rt.[Detenidos por estado de Ebriedad]
from Reporte_semanal_clean rs 
Inner join Regulación_de_Tráfico_clean rt ON rs.Semana = rt.Semana
Order by rs.Semana;
--Evolucion de accidentes por mes--
Select
f.[Mes], SUM(rs.Accidentes) AS Total_Accidentes
from Reporte_semanal_clean rs
Inner join Fecha_clean f ON rs.Semana = f.Semana
Group by f.Mes,
CASE 
	WHEN f.Mes = 'Enero' THEN 1
	WHEN f.Mes = 'Febrero' THEN 2
	WHEN f.Mes = 'Marzo' THEN 3
	WHEN f.Mes = 'Abril' THEN 4
	WHEN f.Mes = 'Mayo' THEN 5
END
Order by 
	CASE
	WHEN f.Mes = 'Enero' THEN 1
	WHEN f.Mes = 'Febrero' THEN 2
	WHEN f.Mes = 'Marzo' THEN 3
	WHEN f.Mes = 'Abril' THEN 4
	WHEN f.Mes = 'Mayo' THEN 5
END;
--Semana mas critica del año--
Select TOP 1 
Semana,
Accidentes,
Lesionados
From Reporte_semanal_clean
Order by Accidentes DESC;
--Regulación policial por mes--
Select 
f.Mes,
SUM(rt.[Vehiculos Requisados]) AS Vehiculos_Requisados,
SUM(rt.[Pruebas de Alcoholemia]) AS Pruebas_Alcoholemia,
SUM(rt.[Ciudadanos Detenidos Sin Licencia]) AS Detenidos_sin_licencia,
SUM(rt.[Detenidos por estado de Ebriedad]) AS Detenidos_Ebrios,
SUM(rt.[Licencias Suspendidas]) AS Licencias_suspendidas
From Regulación_de_Tráfico_clean rt
Inner join Fecha_clean f ON rt.Semana = f.Semana
Group by
f.Mes,
CASE
	WHEN f.Mes = 'Enero' THEN 1
	WHEN f.Mes = 'Febrero' THEN 2
	WHEN f.Mes = 'Marzo' THEN 3
	WHEN f.Mes = 'Abril' THEN 4
	WHEN f.Mes = 'Mayo' THEN 5
END
Order by 
	CASE
	WHEN f.Mes = 'Enero' THEN 1
	WHEN f.Mes = 'Febrero' THEN 2
	WHEN f.Mes = 'Marzo' THEN 3
	WHEN f.Mes = 'Abril' THEN 4
	WHEN f.Mes = 'Mayo' THEN 5
END;
--Promedio de conductores ebrios detectados--
Select
CAST(
	SUM([Detenidos por estado de Ebriedad]) * 100.0 /
	NULLIF(SUM([Vehiculos Requisados]),0)
	AS decimal(10,2)
) AS Porcentaje_ebrios_detectados
From Regulación_de_Tráfico_clean;
--Promedio de conductores sin licencia detectados--
Select
	CAST(
	SUM([Ciudadanos Detenidos Sin Licencia]) * 100.0 /
	NULLIF(SUM([Vehiculos Requisados]),0)
	AS decimal(10,2)
	)AS Porcentaje_sin_licencia
From Regulación_de_Tráfico_clean


------------------Vistas KPI----------------------
Create view vw_kpis_generales AS
Select 
	SUM(Accidentes) AS Total_accidentes,
	SUM(Lesionados) AS Total_lesionados,
	CAST(
	(SUM(Lesionados) * 100.0) /
	NULLIF(SUM(Accidentes),0)
	AS decimal(10,2)
	)AS Porcentaje_lesionados
From Reporte_semanal_clean;
select * from vw_kpis_generales

--Vista accidentes por mes--
Create view vw_Accidentes_por_mes AS
Select 
	f.Mes,
	Case
		WHEN f.Mes = 'Enero' THEN 1
		WHEN f.Mes = 'Febrero' THEN 2
		WHEN f.Mes = 'Marzo' THEN 3
		WHEN f.Mes = 'Abril' THEN 4
		WHEN f.Mes = 'Mayo' THEN 5
	END AS mes_num,
	SUM(rs.Accidentes) AS Total_accidentes
FROM [dbo].[Reporte_semanal_clean] rs
INNER JOIN [dbo].[Fecha_clean] f ON rs.Semana = f.Semana
Group by 
	f.Mes,
	CASE
		WHEN f.Mes = 'Enero' THEN 1
		WHEN f.Mes = 'Febrero' THEN 2
		WHEN f.Mes = 'Marzo' THEN 3
		WHEN f.Mes = 'Abril' THEN 4
		WHEN f.Mes = 'Mayo' THEN 5
	END;
Select * from vw_Accidentes_por_mes

--Vista Departamentos
Create view vw_Departamentos AS
Select 
	[Departamento],
	SUM(Accidentes) AS Total_accidentes,
	CAST(
	SUM(Accidentes) * 100.0 /
	(
		Select SUM(Accidentes)
		From Departamentos_Destacados_clean
	)
	AS decimal(10,2)
)AS Porcentaje_nacional
from Departamentos_Destacados_clean
Group by [Departamento];
Select * from vw_Departamentos

--Vista Vehiculos--
Create view vw_Vehiculos AS
Select 
	[Tipo de Vehiculo],
	SUM(Accidentes) AS Total_accidentes,
	CAST(
		SUM(Accidentes) * 100.0 /
		(
		Select SUM(Accidentes)
		From Tipo_de_Vehiculos_clean
	    )
	AS decimal(10,2)
)AS Porcentaje_nacional
From Tipo_de_Vehiculos_clean
Group by [Tipo de Vehiculo];
Select * from vw_Vehiculos
--Regulacion Policial--

Create view vw_Regulacion AS
Select
	f.Mes,
	CASE 
		WHEN f.Mes = 'Enero' THEN 1
		WHEN f.Mes = 'Febrero' THEN 2
		WHEN f.Mes = 'Marzo' THEN 3
		WHEN f.Mes = 'Abril' THEN 4
		WHEN f.Mes = 'Mayo' THEN 5
	END AS mes_num,
	SUM(rt.[Vehiculos Requisados]) AS Vehiculos_requisados,
	SUM(rt.[Pruebas de Alcoholemia]) AS Pruebas_alcoholemia,
	SUM(rt.[Ciudadanos Detenidos Sin Licencia]) AS Detenidos_sin_licencia,
	SUM(rt.[Detenidos por estado de Ebriedad]) AS Detenidos_ebrios,
	SUM(rt.[Licencias Suspendidas]) AS Licencias_suspendidas
From Regulación_de_Tráfico_clean rt
Inner join Fecha_clean f ON rt.Semana = f.Semana
Group by f.Mes,
	CASE
	WHEN f.Mes = 'Enero' THEN 1
		WHEN f.Mes = 'Febrero' THEN 2
		WHEN f.Mes = 'Marzo' THEN 3
		WHEN f.Mes = 'Abril' THEN 4
		WHEN f.Mes = 'Mayo' THEN 5
	END;
Select * from vw_Regulacion

--Vista Alcohol vs Accidentes
Create view view_Alcohol_vs_accidentes AS
Select
	rs.Semana,
	rs.Accidentes,
	rt.[Detenidos por estado de Ebriedad] AS Detenidos_ebrios
From Reporte_semanal_clean rs
INNER JOIN Regulación_de_Tráfico_clean rt ON rs.Semana = rt.Semana;
Select * from view_Alcohol_vs_accidentes

--Vista semana mas critica--
Create view vw_Semana_critica AS
Select TOP 1
	Semana,
	Accidentes,
	Lesionados
From Reporte_semanal_clean
Order by Accidentes DESC;
Select * from vw_Semana_critica

--Vista Madre--
Create view vw_Fact_accidentes AS
Select
	rs.Semana,
	f.[Fecha Inicio],
	f.[Fecha Cierre],
	f.Mes,
	f.Año,

	rs.Accidentes,
	rs.Lesionados,

	rt.[Vehiculos Requisados],
	rt.[Pruebas de Alcoholemia],
	rt.[Ciudadanos Detenidos Sin Licencia],
	rt.[Detenidos por estado de Ebriedad],
	rt.[Licencias Suspendidas]

From Reporte_semanal_clean rs

Left Join Fecha_clean f ON rs.Semana = f.Semana

Left Join Regulación_de_Tráfico_clean rt ON rs.Semana = rt.Semana;
