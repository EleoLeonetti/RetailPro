/* ============================================================
   VENTAS_TECH_DB  (v2 — incluye tabla Territorio normalizada)
   Fuente: Pipeline_ETL_Dataset.xlsx (TechStore)
   Cambio vs v1: ciudad/país salen de clientes y pasan a Territorio,
   referenciada por clientes.id_territorio (FK). Habilita el JOIN
   de M5 y el mapa por Territorio[Ciudad] de M8.
   ============================================================ */

-- ============================================================
-- 1. CREAR BASE DE DATOS
-- ============================================================
IF DB_ID('Ventas_Tech_DB') IS NULL
BEGIN
    CREATE DATABASE Ventas_Tech_DB;
END
GO

USE Ventas_Tech_DB;
GO

-- ============================================================
-- 2. DROP TABLES (orden inverso de dependencias)
-- ============================================================
IF OBJECT_ID('dbo.ventas', 'U') IS NOT NULL DROP TABLE dbo.ventas;
IF OBJECT_ID('dbo.productos', 'U') IS NOT NULL DROP TABLE dbo.productos;
IF OBJECT_ID('dbo.clientes', 'U') IS NOT NULL DROP TABLE dbo.clientes;
IF OBJECT_ID('dbo.categorias', 'U') IS NOT NULL DROP TABLE dbo.categorias;
IF OBJECT_ID('dbo.territorio', 'U') IS NOT NULL DROP TABLE dbo.territorio;
GO

-- ============================================================
-- 3. CREATE TABLES
-- ============================================================

-- Tabla territorio (nueva)
CREATE TABLE dbo.territorios (
    id_territorio INT           NOT NULL PRIMARY KEY,
    ciudad        VARCHAR(50)   NOT NULL UNIQUE,
    pais          VARCHAR(50)   NOT NULL,
    region        VARCHAR(50)   NULL
);
GO

-- Tabla categorias
CREATE TABLE dbo.categorias (
    id_categoria     INT           NOT NULL PRIMARY KEY,
    nombre_categoria VARCHAR(50)   NOT NULL UNIQUE,
    descripcion      VARCHAR(200)  NULL
);
GO

-- Tabla clientes (ciudad/país reemplazados por FK a territorio)
CREATE TABLE dbo.clientes (
    id_cliente      INT           NOT NULL PRIMARY KEY,
    nombre_cliente  VARCHAR(100)  NOT NULL,
    email           VARCHAR(100)  NULL UNIQUE,
    id_territorio   INT           NULL,          -- NULL = territorio sin asignar (caso Roberto Díaz)
    segmento        VARCHAR(50)   NULL,
    fecha_registro  DATE          NOT NULL,
    CONSTRAINT FK_clientes_territorios FOREIGN KEY (id_territorio)
        REFERENCES dbo.territorios (id_territorio)
);
GO

-- Tabla productos
CREATE TABLE dbo.productos (
    id_producto     INT             NOT NULL PRIMARY KEY,
    nombre_producto VARCHAR(100)    NOT NULL,
    categoria       VARCHAR(50)     NULL,
    subcategoria    VARCHAR(50)     NULL,
    precio          DECIMAL(10,2)   NULL,
    costo           DECIMAL(10,2)   NULL,
    stock           INT             NULL,
    activo          BIT             NOT NULL DEFAULT 1,
    CONSTRAINT FK_productos_categorias FOREIGN KEY (categoria)
        REFERENCES dbo.categorias (nombre_categoria)
);
GO

-- Tabla ventas
CREATE TABLE dbo.ventas (
    id_venta         INT             NOT NULL PRIMARY KEY,
    fecha_venta      DATE            NOT NULL,
    id_cliente       INT             NOT NULL,
    id_producto      INT             NOT NULL,
    cantidad         INT             NOT NULL,
    precio_unitario  DECIMAL(10,2)   NOT NULL,
    descuento        DECIMAL(5,2)    NOT NULL DEFAULT 0,
    total_venta      DECIMAL(10,2)   NOT NULL,
    canal            VARCHAR(20)     NOT NULL,
    CONSTRAINT FK_ventas_clientes  FOREIGN KEY (id_cliente)  REFERENCES dbo.clientes (id_cliente),
    CONSTRAINT FK_ventas_productos FOREIGN KEY (id_producto) REFERENCES dbo.productos (id_producto)
);
GO

-- ============================================================
-- 4. INSERT DATA
-- ============================================================

-- ---- territorio ----
-- Ciudades/países extraídos de la columna original clientes.ciudad/pais.
-- La columna "region" es una agrupación propia (Cono Sur / Región Andina)
-- agregada para enriquecer el ejercicio de JOIN y el mapa de M8; no viene del dataset original.
INSERT INTO dbo.territorios (id_territorio, ciudad, pais, region) VALUES
(1, 'Buenos Aires', 'Argentina', 'Cono Sur'),
(2, 'Córdoba',       'Argentina', 'Cono Sur'),
(3, 'Santiago',      'Chile',     'Cono Sur'),
(4, 'Montevideo',    'Uruguay',   'Cono Sur'),
(5, 'Rosario',       'Argentina', 'Cono Sur'),
(6, 'Lima',          'Perú',      'Región Andina'),
(7, 'Bogotá',        'Colombia',  'Región Andina'),
(8, 'Mendoza',       'Argentina', 'Cono Sur'),
(9, 'Asunción',      'Paraguay',  'Cono Sur');
GO

-- ---- categorias ----
INSERT INTO dbo.categorias (id_categoria, nombre_categoria, descripcion) VALUES
(1, 'Computación',    'Laptops, PCs y monitores'),
(2, 'Accesorios',     'Periféricos y complementos'),
(3, 'Audio',          'Auriculares y parlantes'),
(4, 'Almacenamiento', 'Discos y memorias');
GO

-- ---- clientes ----
-- Nota: la fila duplicada (id_cliente=1) del Excel se insertó una sola vez por la PK.
-- Cliente 11 (Roberto Díaz) queda con id_territorio NULL: en el Excel original
-- tenía ciudad nula, ahora ese hueco se traduce en un territorio sin asignar.
INSERT INTO dbo.clientes (id_cliente, nombre_cliente, email, id_territorio, segmento, fecha_registro) VALUES
(1,  'María López',   'maria@mail.com',   1,    'Retail',      '2022-03-15'),
(2,  'Carlos Ruiz',    'carlos@mail.com',  2,    'Corporativo', '2022-05-20'),
(3,  'Ana Gómez',      'ana@mail.com',     3,    'Retail',      '2022-07-10'),
(4,  'Pedro Sanz',     'pedro@mail.com',   4,    'Corporativo', '2023-01-08'),
(5,  'Laura Torres',   'laura@mail.com',   5,    'Retail',      '2023-02-14'),
(6,  'Diego Mora',     'diego@mail.com',   6,    'Mayorista',   '2023-04-22'),
(7,  'Sofía Reyes',    'sofia@mail.com',   7,    'Retail',      '2023-06-30'),
(8,  'Martín Cruz',    'martin@mail.com',  8,    'Corporativo', '2023-08-05'),
(9,  'Valentina Paz',  NULL,               9,    'Retail',      '2023-09-18'),
(10, 'Lucía Vargas',   'lucia@mail.com',   1,    'Mayorista',   '2023-11-25'),
(11, 'Roberto Díaz',   'roberto@mail.com', NULL, 'Retail',      '2024-01-10');
GO

-- ---- productos ----
-- Nota: la fila duplicada (id_producto=103) del Excel se insertó una sola vez por la PK.
INSERT INTO dbo.productos (id_producto, nombre_producto, categoria, subcategoria, precio, costo, stock, activo) VALUES
(101, 'Laptop Pro 15',        'Computación',    'Laptops',     1200, 850,  15, 1),
(102, 'Mouse Inalámbrico',    'Accesorios',     'Periféricos', 28,   12,   80, 1),
(103, 'Monitor 4K 27"',       'Computación',    'Monitores',   450,  300,  12, 1),
(104, 'Teclado Mecánico',     'Accesorios',     'Periféricos', 95,   48,   40, 1),
(105, 'Laptop Basic 14',      'Computación',    'Laptops',     650,  420,  20, 1),
(106, 'Auriculares BT Pro',   'Audio',          'Auriculares', 120,  62,   35, 1),
(107, 'Hub USB-C 7p',         'Accesorios',     'Periféricos', 45,   20,   60, 1),
(108, 'Webcam HD 1080p',      'Accesorios',     'Periféricos', 85,   42,   25, 1),
(109, 'SSD Externo 1TB',      'Almacenamiento', 'Discos',      NULL, 75,   18, 1),
(110, 'Parlante Bluetooth',   'Audio',          'Parlantes',   60,   28,   45, 1),
(111, 'Laptop Gaming Pro',    NULL,             'Laptops',     1800, 1350, 8,  1),
(112, 'Pad Mouse XL',         'Accesorios',     'Periféricos', 22,   8,    0,  0);
GO

-- ---- ventas ----
INSERT INTO dbo.ventas (id_venta, fecha_venta, id_cliente, id_producto, cantidad, precio_unitario, descuento, total_venta, canal) VALUES
(1001, '2023-01-10', 1,  101, 2,  1200, 0,    2400,   'Online'),
(1002, '2023-01-15', 2,  102, 5,  28,   0,    140,    'Presencial'),
(1003, '2023-01-22', 3,  103, 1,  450,  0.05, 427.5,  'Online'),
(1004, '2023-02-05', 4,  104, 3,  95,   0,    285,    'Presencial'),
(1005, '2023-02-14', 5,  105, 2,  650,  0,    1300,   'Online'),
(1006, '2023-02-28', 1,  106, 4,  120,  0.1,  432,    'Online'),
(1007, '2023-03-08', 6,  107, 6,  45,   0,    270,    'Presencial'),
(1008, '2023-03-15', 7,  108, 2,  85,   0,    170,    'Online'),
(1009, '2023-03-22', 8,  109, 3,  130,  0.05, 370.5,  'Presencial'),
(1010, '2023-04-03', 9,  110, 5,  60,   0,    300,    'Online'),
(1011, '2023-04-18', 10, 111, 1,  1800, 0,    1800,   'Online'),
(1012, '2023-04-25', 2,  101, 1,  1200, 0,    1200,   'Presencial'),
(1013, '2023-05-06', 3,  102, 8,  28,   0,    224,    'Online'),
(1014, '2023-05-20', 4,  103, 2,  450,  0.1,  810,    'Presencial'),
(1015, '2023-05-30', 5,  104, 4,  95,   0,    380,    'Online'),
(1016, '2023-06-08', 6,  105, 2,  650,  0,    1300,   'Presencial'),
(1017, '2023-06-15', 7,  106, 3,  120,  0.05, 342,    'Online'),
(1018, '2023-06-28', 8,  109, 2,  130,  0,    260,    'Online'),
(1019, '2023-07-05', 9,  110, 6,  60,   0,    360,    'Presencial'),
(1020, '2023-07-19', 10, 108, 3,  85,   0,    255,    'Online'),
(1021, '2023-08-02', 1,  111, 2,  1800, 0.1,  3240,   'Online'),
(1022, '2023-08-14', 2,  102, 10, 28,   0,    280,    'Presencial'),
(1023, '2023-08-25', 3,  105, 1,  650,  0,    650,    'Online'),
(1024, '2023-09-10', 4,  106, 5,  120,  0.05, 570,    'Presencial'),
(1025, '2023-09-22', 5,  103, 3,  450,  0,    1350,   'Online'),
(1026, '2023-10-04', 6,  101, 1,  1200, 0,    1200,   'Presencial'),
(1027, '2023-10-18', 7,  107, 8,  45,   0,    360,    'Online'),
(1028, '2023-11-06', 8,  104, 6,  95,   0.1,  513,    'Presencial'),
(1029, '2023-11-20', 9,  109, 4,  130,  0,    520,    'Online'),
(1030, '2023-12-05', 10, 111, 3,  1800, 0,    5400,   'Online'),
(1031, '2023-12-15', 1,  110, 7,  60,   0,    420,    'Presencial'),
(1032, '2023-12-28', 2,  105, 2,  650,  0.05, 1235,   'Online'),
(1033, '2024-01-08', 3,  101, 2,  1200, 0,    2400,   'Online'),
(1034, '2024-01-15', 4,  102, 6,  28,   0,    168,    'Presencial'),
(1035, '2024-01-25', 5,  103, 1,  450,  0,    450,    'Online'),
(1036, '2024-02-03', 6,  104, 4,  95,   0.1,  342,    'Presencial'),
(1037, '2024-02-14', 7,  106, 3,  120,  0,    360,    'Online'),
(1038, '2024-02-22', 8,  109, 2,  130,  0.05, 247,    'Online'),
(1039, '2024-03-05', 9,  111, 1,  1800, 0,    1800,   'Presencial'),
(1040, '2024-03-18', 10, 105, 3,  650,  0,    1950,   'Online'),
(1041, '2024-03-28', 1,  107, 10, 45,   0,    450,    'Presencial'),
(1042, '2024-04-06', 2,  108, 4,  85,   0,    340,    'Online'),
(1043, '2024-04-20', 3,  110, 8,  60,   0.05, 456,    'Presencial'),
(1044, '2024-05-04', 4,  101, 2,  1200, 0,    2400,   'Online'),
(1045, '2024-05-18', 5,  103, 3,  450,  0,    1350,   'Presencial'),
(1046, '2024-06-02', 6,  106, 5,  120,  0.1,  540,    'Online'),
(1047, '2024-06-15', 7,  109, 3,  130,  0,    390,    'Presencial'),
(1048, '2024-06-28', 8,  111, 2,  1800, 0,    3600,   'Online'),
(1049, '2024-07-10', 9,  102, 12, 28,   0,    336,    'Presencial'),
(1050, '2024-07-22', 10, 105, 2,  650,  0.05, 1235,   'Online');
GO

-- ============================================================
-- 5. VERIFICACIÓN RÁPIDA
-- ============================================================
SELECT 'territorio' AS tabla, COUNT(*) AS filas FROM dbo.territorios
UNION ALL SELECT 'categorias', COUNT(*) FROM dbo.categorias
UNION ALL SELECT 'clientes',   COUNT(*) FROM dbo.clientes
UNION ALL SELECT 'productos',  COUNT(*) FROM dbo.productos
UNION ALL SELECT 'ventas',     COUNT(*) FROM dbo.ventas;
GO

-- Ejemplo de JOIN para el ejercicio de M5:
-- ventas de cada cliente enriquecidas con su ciudad/país/región
/*
SELECT v.id_venta, c.nombre_cliente, t.ciudad, t.pais, t.region, v.total_venta
FROM dbo.ventas v
INNER JOIN dbo.clientes c   ON v.id_cliente = c.id_cliente
LEFT JOIN  dbo.territorio t ON c.id_territorio = t.id_territorio;
-- LEFT JOIN porque Roberto Díaz (cliente 11) no tiene territorio asignado
*/
