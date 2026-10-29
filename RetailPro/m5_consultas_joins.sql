-- -------------------------------------------------------
-- RetailPro — Pre-entrega 5: Consultas con JOINs para el proyecto
-- TÍTULO: Cruzando tablas para enriquecer el análisis
-- Base de datos: Ventas_Tech_DB (creada en el Módulo 3) + 2 nuevos registros
-- ALUMNO: Somavilla Ignacio
-- -------------------------------------------------------

USE Ventas_Tech_DB;
-- inserto registros en mi tabla de base de datos: Ventas_Tech_DB
-- en las tablas de clientes y productos
-- para que en la consultas 2 y3 de la entrega, no me devuelva 0 filas 
INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro)
VALUES (6, 'Julián Díaz', 'julian@mail.com', 'Córdoba', '2024-03-10'), 
       (7, 'Sofía Herrera', 'sofia@mail.com',  'Salta', '2024-03-14');

INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo)
VALUES (7, 'Webcam HD 1080p',    2,   85.00, 25, 1),
       (8, 'Parlante Bluetooth', 3,   60.00, 45, 1);

-- -------------------------------------------------------
-- Consulta 1 — Vista base del proyecto (INNER JOIN)
-- Propósito: una sola tabla con cada venta y su contexto (cliente, ciudad, producto
-- y categoría). Es la fuente principal del dashboard de Power BI (M7):
-- categoria sirve para agrupar y ciudad para filtrar.
-- INNER JOIN porque cada venta tiene que tener cliente, producto y categoría válidos.
-- Control: tienen que salir 10 filas, las mismas que tiene ventas. Si salieran menos,
-- alguna venta no encontró su pareja en otra tabla y el INNER JOIN la descartó.
SELECT
    v.id_venta,
    v.fecha_venta,
    c.id_cliente,
    c.nombre                        AS cliente,
    c.ciudad,
    p.nombre_producto               AS producto,
    cat.nombre_categoria            AS categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario  AS total_venta
FROM ventas AS v
INNER JOIN clientes   AS c   ON v.id_cliente   = c.id_cliente
INNER JOIN productos  AS p   ON v.id_producto  = p.id_producto
INNER JOIN categorias AS cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta, v.id_venta;
-- Hallazgo: salen 10 filas (ninguna venta se perdió en el cruce) que suman $6.444, igual que en M4.
--           Con la categoría en cada fila se ve que Computación concentra $4.950, el 76,8 % de la facturación.


-- -------------------------------------------------------
-- Consulta 2 — Clientes sin ventas (LEFT JOIN)
-- Propósito: detectar clientes registrados que nunca compraron, para que CRM los contacte.
-- El LEFT JOIN conserva a todos los clientes; los que no tienen ventas quedan con las
-- columnas de ventas en NULL. Filtro por id_venta porque es la PK de ventas: en una venta
-- real nunca es NULL, así que si aparece NULL es que ese cliente no tuvo ninguna venta.
SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes AS c
LEFT JOIN ventas AS v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL
ORDER BY c.fecha_registro;
-- Hallazgo: 2 de los 7 clientes registrados (29 %) nunca compraron: Julián Díaz y Sofía Herrera.
--           Los dos se registraron en marzo de 2024; CRM puede contactarlos vía mail con una oferta de bienvenida antes de perderlos.


-- -------------------------------------------------------
-- Consulta 3 — Productos sin ventas (LEFT JOIN)
-- Propósito: identificar artículos del catálogo sin movimiento, para que el área de producto
-- revise precio, visibilidad o continuidad.
-- También uso LEFT JOIN con categorias: si un producto no tuviera categoría cargada, un INNER
-- lo haría desaparecer, y acá quiero ver todo el catálogo.
-- Sumo stock (no lo pide la consigna) para medir cuánta mercadería está parada.
SELECT
    p.nombre_producto,
    cat.nombre_categoria  AS categoria,
    p.precio,
    p.stock
FROM productos AS p
LEFT JOIN categorias AS cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas     AS v   ON p.id_producto  = v.id_producto
WHERE v.id_venta IS NULL
ORDER BY p.nombre_producto;
-- Hallazgo: 2 de los 8 productos (25 %) no tienen ventas: Parlante Bluetooth (Audio) y Webcam HD 1080p (Accesorios).
--           Suman 70 unidades en stock, unos $4.825 a precio de venta sin rotar; producto debería evaluar una promoción o su continuidad.


-- ----------------------------------------------------------------------------------------------- 
--Consulta 4 — Consolidado por zona (UNION ALL)
-- Propósito: comparar cuánto factura Buenos Aires contra el Interior.
-- Mi esquema no tiene canal de venta, así que uso como criterio la ciudad del cliente,
-- que es la dimensión geográfica que modelé. La columna zona no existe en ninguna tabla:
-- la creo como texto fijo en cada SELECT.
-- Las dos condiciones del WHERE son complementarias; el OR ... IS NULL hace que un cliente
-- sin ciudad cargada no se pierda (ciudad <> 'Buenos Aires' da falso con NULL).
-- UNION ALL y no UNION: dos ventas idénticas en fecha y total son ventas distintas y las dos
-- tienen que sumar. Control: cantidad_ventas tiene que dar 10 entre las dos zonas.
-- -----------------------------------------------------------------------------------------------
SELECT
    zona,
    COUNT(*)    AS cantidad_ventas,
    SUM(total)  AS total_zona
FROM (
    SELECT v.fecha_venta, v.cantidad * v.precio_unitario AS total, 'Buenos Aires' AS zona
    FROM ventas AS v
    INNER JOIN clientes AS c ON v.id_cliente = c.id_cliente
    WHERE c.ciudad = 'Buenos Aires'

    UNION ALL

    SELECT v.fecha_venta, v.cantidad * v.precio_unitario AS total, 'Interior' AS zona
    FROM ventas AS v
    INNER JOIN clientes AS c ON v.id_cliente = c.id_cliente
    WHERE c.ciudad <> 'Buenos Aires' OR c.ciudad IS NULL
) AS consolidado
GROUP BY zona
ORDER BY total_zona DESC;
-- Hallazgo: el Interior factura más ($3.804, 59 %) con 8 ventas de 4 clientes; Buenos Aires aporta $2.640 (41 %)
--           con una sola clienta y 2 ventas: su ticket promedio ($1.320) casi triplica al del Interior ($475,50).-- -------------------------------------------------------
-- RetailPro — Pre-entrega 5: Consultas con JOINs para el proyecto
-- TÍTULO: Cruzando tablas para enriquecer el análisis
-- Base de datos: Ventas_Tech_DB (creada en el Módulo 3) + 2 nuevos registros
-- ALUMNO: Somavilla Ignacio
-- -------------------------------------------------------

USE Ventas_Tech_DB;
-- inserto registros en mi tabla de base de datos: Ventas_Tech_DB
-- en las tablas de clientes y productos
-- para que en la consultas 2 y3 de la entrega, no me devuelva 0 filas 
INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro)
VALUES (6, 'Julián Díaz', 'julian@mail.com', 'Córdoba', '2024-03-10'), 
       (7, 'Sofía Herrera', 'sofia@mail.com',  'Salta', '2024-03-14');

INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo)
VALUES (7, 'Webcam HD 1080p',    2,   85.00, 25, 1),
       (8, 'Parlante Bluetooth', 3,   60.00, 45, 1);

-- -------------------------------------------------------
-- Consulta 1 — Vista base del proyecto (INNER JOIN)
-- Propósito: una sola tabla con cada venta y su contexto (cliente, ciudad, producto
-- y categoría). Es la fuente principal del dashboard de Power BI (M7):
-- categoria sirve para agrupar y ciudad para filtrar.
-- INNER JOIN porque cada venta tiene que tener cliente, producto y categoría válidos.
-- Control: tienen que salir 10 filas, las mismas que tiene ventas. Si salieran menos,
-- alguna venta no encontró su pareja en otra tabla y el INNER JOIN la descartó.
SELECT
    v.id_venta,
    v.fecha_venta,
    c.id_cliente,
    c.nombre                        AS cliente,
    c.ciudad,
    p.nombre_producto               AS producto,
    cat.nombre_categoria            AS categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario  AS total_venta
FROM ventas AS v
INNER JOIN clientes   AS c   ON v.id_cliente   = c.id_cliente
INNER JOIN productos  AS p   ON v.id_producto  = p.id_producto
INNER JOIN categorias AS cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta, v.id_venta;
-- Hallazgo: salen 10 filas (ninguna venta se perdió en el cruce) que suman $6.444, igual que en M4.
--           Con la categoría en cada fila se ve que Computación concentra $4.950, el 76,8 % de la facturación.


-- -------------------------------------------------------
-- Consulta 2 — Clientes sin ventas (LEFT JOIN)
-- Propósito: detectar clientes registrados que nunca compraron, para que CRM los contacte.
-- El LEFT JOIN conserva a todos los clientes; los que no tienen ventas quedan con las
-- columnas de ventas en NULL. Filtro por id_venta porque es la PK de ventas: en una venta
-- real nunca es NULL, así que si aparece NULL es que ese cliente no tuvo ninguna venta.
SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes AS c
LEFT JOIN ventas AS v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL
ORDER BY c.fecha_registro;
-- Hallazgo: 2 de los 7 clientes registrados (29 %) nunca compraron: Julián Díaz y Sofía Herrera.
--           Los dos se registraron en marzo de 2024; CRM puede contactarlos vía mail con una oferta de bienvenida antes de perderlos.


-- -------------------------------------------------------
-- Consulta 3 — Productos sin ventas (LEFT JOIN)
-- Propósito: identificar artículos del catálogo sin movimiento, para que el área de producto
-- revise precio, visibilidad o continuidad.
-- También uso LEFT JOIN con categorias: si un producto no tuviera categoría cargada, un INNER
-- lo haría desaparecer, y acá quiero ver todo el catálogo.
-- Sumo stock (no lo pide la consigna) para medir cuánta mercadería está parada.
SELECT
    p.nombre_producto,
    cat.nombre_categoria  AS categoria,
    p.precio,
    p.stock
FROM productos AS p
LEFT JOIN categorias AS cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas     AS v   ON p.id_producto  = v.id_producto
WHERE v.id_venta IS NULL
ORDER BY p.nombre_producto;
-- Hallazgo: 2 de los 8 productos (25 %) no tienen ventas: Parlante Bluetooth (Audio) y Webcam HD 1080p (Accesorios).
--           Suman 70 unidades en stock, unos $4.825 a precio de venta sin rotar; producto debería evaluar una promoción o su continuidad.


-- ----------------------------------------------------------------------------------------------- 
--Consulta 4 — Consolidado por zona (UNION ALL)
-- Propósito: comparar cuánto factura Buenos Aires contra el Interior.
-- Mi esquema no tiene canal de venta, así que uso como criterio la ciudad del cliente,
-- que es la dimensión geográfica que modelé. La columna zona no existe en ninguna tabla:
-- la creo como texto fijo en cada SELECT.
-- Las dos condiciones del WHERE son complementarias; el OR ... IS NULL hace que un cliente
-- sin ciudad cargada no se pierda (ciudad <> 'Buenos Aires' da falso con NULL).
-- UNION ALL y no UNION: dos ventas idénticas en fecha y total son ventas distintas y las dos
-- tienen que sumar. Control: cantidad_ventas tiene que dar 10 entre las dos zonas.
-- -----------------------------------------------------------------------------------------------
SELECT
    zona,
    COUNT(*)    AS cantidad_ventas,
    SUM(total)  AS total_zona
FROM (
    SELECT v.fecha_venta, v.cantidad * v.precio_unitario AS total, 'Buenos Aires' AS zona
    FROM ventas AS v
    INNER JOIN clientes AS c ON v.id_cliente = c.id_cliente
    WHERE c.ciudad = 'Buenos Aires'

    UNION ALL

    SELECT v.fecha_venta, v.cantidad * v.precio_unitario AS total, 'Interior' AS zona
    FROM ventas AS v
    INNER JOIN clientes AS c ON v.id_cliente = c.id_cliente
    WHERE c.ciudad <> 'Buenos Aires' OR c.ciudad IS NULL
) AS consolidado
GROUP BY zona
ORDER BY total_zona DESC;
-- Hallazgo: el Interior factura más ($3.804, 59 %) con 8 ventas de 4 clientes; Buenos Aires aporta $2.640 (41 %)
--           con una sola clienta y 2 ventas: su ticket promedio ($1.320) casi triplica al del Interior ($475,50).
