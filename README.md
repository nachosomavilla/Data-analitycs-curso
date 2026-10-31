# RetailPro — Análisis de ventas

Proyecto del curso de Data Analytics. Es una base de datos de ventas de una tienda de productos tecnológicos, armada en SQL Server, con consultas de negocio para el equipo comercial: facturación mensual, ranking de productos, clientes recurrentes, clientes y productos sin ventas y comparación por zona.

## Herramientas

- SQL Server y SQL Server Management Studio (SSMS)
- Power BI Desktop (dashboard, en desarrollo)
- GitHub

## Estructura del repositorio

```
MODULO3/
  ventas_tech_db.sql         -> crea y carga las tablas de Ventas_Tech_DB
RetailPro/
  m4_consultas_negocio.sql   -> métricas de negocio (Pre-entrega 4)
  m5_consultas_joins.sql     -> consultas con JOINs y UNION ALL (Pre-entrega 5)
```

## Modelo de datos

```
categorias (1) ── (N) productos (1) ── (N) ventas (N) ── (1) clientes
```

`ventas` es la tabla de hechos y guarda el precio al momento de la venta, así un cambio de precio posterior no altera los totales históricos.

## Cómo ejecutar los scripts

1. Abrí SSMS y conectate con servidor `localhost` (o `.\SQLEXPRESS` si usás la edición Express), Autenticación de Windows y la opción **Certificado de servidor de confianza** tildada.
2. Creá la base, porque `ventas_tech_db.sql` no la crea:

   ```sql
   CREATE DATABASE Ventas_Tech_DB;
   ```

3. Seleccioná `Ventas_Tech_DB` en el desplegable de bases de datos y ejecutá con F5, en este orden:
   1. `MODULO3/ventas_tech_db.sql`: borra las tablas si existen, las crea y carga 25 registros.
   2. `RetailPro/m4_consultas_negocio.sql`
   3. `RetailPro/m5_consultas_joins.sql`

> **Importante:** `m5_consultas_joins.sql` inserta 2 clientes (id 6 y 7) y 2 productos (id 7 y 8). Ejecutalo una sola vez: si lo corrés de nuevo, da error de clave primaria. Para repetir todo desde cero, volvé a ejecutar primero `ventas_tech_db.sql`.

## Próximos pasos

- Dashboard en Power BI (Módulo 7), usando como fuente la vista base de la Consulta 1 de `m5`.

## Autor

Ignacio Somavilla
