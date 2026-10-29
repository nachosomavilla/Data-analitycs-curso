-- --------------------------------------------------------------- 
-- RetailPro — Pre-entrega 4: Consultas SQL de negocio
-- TÍTULO: Extrayendo métricas clave con SQL
-- Base de datos: Ventas_Tech_DB (creada en el Módulo 3)
-- ALUMNO: Somavilla Ignacio
-- ----------------------------------------------------------------

USE Ventas_Tech_DB;
-- Se trabaja sobre la tabla creada en la pre-entrega anterior
-- ----------------------------------------------------------------
-- Consulta 1 — Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio por mes.

SELECT
    MONTH(fecha_venta)                                     AS mes,
    SUM(cantidad * precio_unitario)                        AS total_facturado,
    COUNT(*)                                               AS cantidad_pedidos,
    AVG(cantidad * precio_unitario)                        AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta);

-- Consulta 2 — Ranking de productos
-- Top 5 de productos por total facturado, con las unidades vendidas.
-- Se ordena de mayor a menor facturación y TOP 5 se queda con los cinco primeros.
SELECT TOP 5
    id_producto,
    SUM(cantidad)                    AS unidades_vendidas,
    SUM(cantidad * precio_unitario)  AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;


-- Consulta 3 — Clientes recurrentes 
-- Clientes con más de un pedido, con su cantidad de pedidos y el  total gastado. 
-- HAVING filtra después de agrupar (WHERE no puede filtrar por COUNT).
SELECT
    id_cliente,
    COUNT(*)                         AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)  AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;



-- Consulta 4 — Meses por encima/por debajo del promedio 
-- Primero se calcula el total facturado de cada mes (totales_mensuales).
-- Después se compara cada mes contra el promedio de esos totales mensuales y se etiqueta con CASE WHEN.
WITH totales_mensuales AS (
    SELECT
        MONTH(fecha_venta)               AS mes,
        SUM(cantidad * precio_unitario)  AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
)
SELECT
    mes,
    total_facturado,
    CASE
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM totales_mensuales)
            THEN 'Por encima'
        WHEN total_facturado < (SELECT AVG(total_facturado) FROM totales_mensuales)
            THEN 'Por debajo'
        ELSE 'Igual al promedio'
    END AS comparacion_promedio
FROM totales_mensuales;




-- ----------------------------------------------------------------
-- CONCLUSIONES Y HALLAZGOS DE NEGOCIO
-- ----------------------------------------------------------------
-- 1. El producto 1 (Laptop Pro 15) es el de mayor facturación, con $3.600, lo que representa el 55,9 % del total mensual. 
--    Por su parte, el producto 3 (Monitor 4K 27) genera $1.350 de ingresos.
--    En conjunto, ambos productos concentran el 76,8 %, es decir más de tres cuartos de los ingresos totales.
--    En contraste El producto 2 (Mouse Inalámbrico) lidera en unidades vendidas, con un total de 13, más del triple que cualquier otro producto.
--    Sin embargo, ocupa el quinto lugar en facturación, con $364, debido a su bajo precio unitario.
--    Esto demuestra que vender más unidades no necesariamente implica generar mayores ingresos.

-- 2. Los cinco clientes presentan un comportamiento de compra recurrente, con dos pedidos cada uno.
--    Sin embargo, el gasto se concentra principalmente en los clientes 1 y 5
--    que acumulan $4.740, equivalente al 73,6 % de la facturación total. 
--    Ambos clientes compraron el producto 1 (Laptop Pro 15), lo que evidencia su influencia en los ingresos del período.
--
-- 3. Todas las ventas registradas corresponden a marzo de 2024, por lo que las consultas 1 y 4 muestran únicamente ese mes, 
--    con una facturación total de $6.444, 10 pedidos y un ticket promedio de $644,40.
--    Por este motivo, la comparación con el promedio indica que marzo se encuentra en igualdad con dicho valor.
--    Al incorporar datos de otros meses,la consulta 4 permitirá identificar los períodos con resultados 
--    superiores e inferiores al promedio sin necesidad de modificar el código.
