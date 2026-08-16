USE Ventas_Tech_DB;

--CONSULTA 1: Vista base del proyecto

SELECT
    v.fecha_venta,
    c.nombre_cliente,
    c.segmento,
    t.region,
    p.nombre_producto,
    cat.nombre_categoria,
    v.cantidad,
    v.precio_unitario,
    v.total_venta,
    v.canal
FROM ventas AS v
INNER JOIN clientes AS c
    ON v.id_cliente = c.id_cliente
INNER JOIN productos AS p
    ON v.id_producto = p.id_producto
INNER JOIN categorias AS cat
    ON p.categoria = cat.nombre_categoria
INNER JOIN territorios AS t
    ON c.id_territorio = t.id_territorio;

--CONSULTA 2: Clientes sin ventas

SELECT
    c.nombre_cliente,
    c.email,
    c.fecha_registro
FROM clientes AS c
LEFT JOIN ventas AS v
    ON c.id_cliente = v.id_cliente
WHERE v.id_cliente IS NULL;

--CONSULTA 3: Productos sin ventas

SELECT
    p.nombre_producto,
    p.categoria,
    p.precio
FROM productos AS p
LEFT JOIN ventas AS v
    ON p.id_producto = v.id_producto
WHERE v.id_producto IS NULL;

--CONSULTA 4: Consolidado por canal

SELECT
    canal,
    SUM(total_venta) AS total_facturado
FROM (
    SELECT
        total_venta,
        'Online' AS canal
    FROM ventas
    WHERE canal = 'Online'

    UNION ALL

    SELECT
        total_venta,
        'Presencial' AS canal
    FROM ventas
    WHERE canal = 'Presencial'
) AS ventas_canales
GROUP BY canal;