--CONSULTA 1: Resumen ejecutivo mensual
--Total facturado, cantidad de pedidos y ticket promedio por mes

SELECT
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY MONTH(fecha_venta);

--CONSULTA 2: Ranking de productos
--Top 5 de id_productos por total facturado. Mostrando: unidades vendidas y total generado

SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY SUM(cantidad * precio_unitario) DESC;

--CONSULTA 3: Clientes que hayan realizado más de un pedido
-- id_clientes que realizaron más de un pedido mostrando cantidad y total gastado

SELECT
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1;

--CONSULTA 4: Meses por encima/por debajo del promedio
--Total facturado por mes indicando "Por encima" o "Por debajo" de promedio mensual general

SELECT
    mes,
    total_facturado,
    CASE
        WHEN total_facturado > promedio_mensual THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparacion_promedio
FROM (
    SELECT
        MONTH(fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado,
        (
            SELECT AVG(total_mensual)
            FROM (
                SELECT
                    MONTH(fecha_venta) AS mes,
                    SUM(cantidad * precio_unitario) AS total_mensual
                FROM ventas
                GROUP BY MONTH(fecha_venta)
            ) AS promedio
        ) AS promedio_mensual
    FROM ventas
    GROUP BY MONTH(fecha_venta)
) AS resumen
ORDER BY mes;

/*
HALLAZGO 1:
Diciembre registra la mayor facturación mensual ($7.120) con solo 3 pedidos,
impulsada por el ticket promedio más alto del período ($2.373,33).

HALLAZGO 2:
El producto 111 lidera la facturación con $16.200, aunque solo vendió 9 unidades, lo que indica que su aporte a la facturación está impulsado por su alto valor por unidad.

HALLAZGO 3:
El cliente 10 registra el mayor gasto total con $10.705 en 5 pedidos, mientras que el cliente 7 registra el menor con $1.640 en la misma cantidad de pedidos.

HALLAZGO 4:
7 de los 12 meses se encuentran por encima del promedio mensual general de $4.040,67, mientras que 5 meses quedan por debajo.
*/