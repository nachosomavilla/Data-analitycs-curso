-- Motor utilizado: SQL Server (SSMS)
-- ------------------------------------------------------------------
-- ALUMNO: Somavilla Ignacio
-- ENTREGABLE 3: Checkpoint 3 — Script ventas_tech_db.sql
-- Modelo relacional:
--   categorias (1) ── (N) productos (1) ── (N) ventas (N) ── (1) clientes
-- ------------------------------------------------------------------
-- === SECCIÓN 1: DROP ===
-- ------------------------------------------------------------------
-- Borro en orden INVERSO a las dependencias: primero la tabla que tiene FK hacia las demás (ventas) y al final la que no depende de nadie
-- (categorias). Si borrara categorias primero, productos todavía la  estaría referenciando y el motor rechazaría el DROP.

DROP TABLE IF EXISTS ventas;       -- referencia a clientes y productos
DROP TABLE IF EXISTS productos;    -- referencia a categorias
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS categorias;
GO


-- ------------------------------------------------------------------
-- === SECCIÓN 2: CREATE ===
--------------------------------------------------------------------
-- Orden: primero las dimensiones que no dependen de nadie
-- (categorias, clientes), después productos y al final la tabla de
-- hechos (ventas). Si creara ventas primero, sus FK no encontrarían a qué tabla apuntar (el error del "huevo y la gallina").

-- Crear tabla categorias
CREATE TABLE categorias (
    id_categoria INT PRIMARY KEY,
    nombre_categoria VARCHAR(50) NOT NULL,
    descripcion VARCHAR(200)               -- opcional, texto descriptivo
);

-- Crear tabla clientes
CREATE TABLE clientes (
    id_cliente INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,            -- UNIQUE: no puede haber dos clientes con el mismo email
    ciudad VARCHAR(50),
    fecha_registro DATE NOT NULL         -- DATE y no VARCHAR: permite análisis temporal en Power BI
);

-- Crear tabla productos
CREATE TABLE productos (
    id_producto INT PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    id_categoria INT,                       -- mismo tipo (INT) que la PK a la que apunta
    precio DECIMAL(10,2) NOT NULL,          -- dinero: DECIMAL es exacto, FLOAT guarda aproximaciones
    stock INT DEFAULT 0,                    -- si no se informa, arranca en 0 unidades
    activo BIT DEFAULT 1,                   -- booleano en SQL Server: 1 = activo, 0 = descontinuado
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);

-- Crear tabla ventas
-- Cada fila es una venta: conecta un cliente con un producto y guarda las métricas numéricas (cantidad y precio).
CREATE TABLE ventas (
    id_venta INT PRIMARY KEY,
    id_cliente INT,
    id_producto INT,
    cantidad INT NOT NULL,                  -- unidades enteras, no hay "medio mouse"
    precio_unitario DECIMAL(10,2) NOT NULL, -- guardo el precio AL MOMENTO de la venta: si mañana  cambia el precio, el anterior no se altera
    fecha_venta DATE NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);
GO


-- ------------------------------------------------------------------
-- === SECCIÓN 3: INSERT ===
-- ------------------------------------------------------------------
-- Mismo orden lógico que el CREATE: primero las tablas sin dependencias.
-- Las columnas van explicitadas en cada INSERT: si mañana se agrega una columna a la tabla, estos INSERT siguen funcionando.
-- Total: 4 + 5 + 6 + 10 = 25 registros.

-- categorias — 4 registros
INSERT INTO categorias (id_categoria, nombre_categoria, descripcion) VALUES
  (1, 'Computación',    'Laptops, PCs y monitores'),
  (2, 'Accesorios',     'Periféricos y complementos'),
  (3, 'Audio',          'Auriculares y parlantes'),
  (4, 'Almacenamiento', 'Discos y memorias');

-- clientes — 5 registros
INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro) VALUES
  (1, 'María López',  'maria@mail.com',  'Buenos Aires', '2024-01-05'),
  (2, 'Carlos Ruiz',  'carlos@mail.com', 'Córdoba',      '2024-01-10'),
  (3, 'Ana Gómez',    'ana@mail.com',    'Rosario',      '2024-02-01'),
  (4, 'Pedro Sanz',   'pedro@mail.com',  'Mendoza',      '2024-02-15'),
  (5, 'Laura Torres', 'laura@mail.com',  'Tucumán',      '2024-03-01');

-- productos — 6 registros (necesita que categorias ya esté cargada)
INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo) VALUES
  (1, 'Laptop Pro 15',      1, 1200.00, 15, 1),
  (2, 'Mouse Inalámbrico',  2,   28.00, 80, 1),
  (3, 'Monitor 4K 27',      1,  450.00, 12, 1),
  (4, 'Auriculares BT Pro', 3,  120.00, 35, 1),
  (5, 'SSD Externo 1TB',    4,  130.00, 18, 1),
  (6, 'Teclado Mecánico',   2,   95.00, 40, 1);

-- ventas — 10 registros (necesita que clientes y productos ya estén cargadas)
INSERT INTO ventas (id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta) VALUES
  ( 1, 1, 1, 2, 1200.00, '2024-03-05'),
  ( 2, 2, 2, 5,   28.00, '2024-03-06'),
  ( 3, 3, 3, 1,  450.00, '2024-03-07'),
  ( 4, 1, 4, 2,  120.00, '2024-03-08'),
  ( 5, 4, 5, 3,  130.00, '2024-03-10'),
  ( 6, 2, 6, 4,   95.00, '2024-03-11'),
  ( 7, 5, 1, 1, 1200.00, '2024-03-12'),
  ( 8, 3, 2, 8,   28.00, '2024-03-13'),
  ( 9, 4, 4, 1,  120.00, '2024-03-14'),
  (10, 5, 3, 2,  450.00, '2024-03-15');
GO


-- ------------------------------------------------------------------
-- === SECCIÓN 4: VALIDACIÓN ===
-- ------------------------------------------------------------------
-- Confirmo que las cuatro tablas cargaron bien.
-- Esperado: 4, 5, 6 y 10 filas respectivamente (25 en total).

SELECT * FROM categorias;   -- esperado: 4 filas
SELECT * FROM clientes;     -- esperado: 5 filas
SELECT * FROM productos;    -- esperado: 6 filas
SELECT * FROM ventas;       -- esperado: 10 filas

