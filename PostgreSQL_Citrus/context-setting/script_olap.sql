--Volumen de transacciones por país

SELECT
p.nombre,
COUNT(t.id_transaccion)
FROM transacciones t
JOIN cuentas c ON t.cuenta_origen = c.id_cuenta
JOIN paises p ON c.id_pais = p.id_pais
GROUP BY p.nombre;

--Monto total movido por moneda

SELECT
moneda,
SUM(monto)
FROM transacciones
GROUP BY moneda;

--Clientes con mayor volumen de transferencias

SELECT
c.id_cliente,
SUM(t.monto) total
FROM clientes c
JOIN cuentas cu ON cu.id_cliente = c.id_cliente
JOIN transacciones t ON t.cuenta_origen = cu.id_cuenta
GROUP BY c.id_cliente
ORDER BY total DESC
LIMIT 10;

--Flujo de dinero entre países

SELECT
po.nombre pais_origen,
pd.nombre pais_destino,
SUM(t.monto) total
FROM transacciones t
JOIN cuentas co ON t.cuenta_origen = co.id_cuenta
JOIN cuentas cd ON t.cuenta_destino = cd.id_cuenta
JOIN paises po ON co.id_pais = po.id_pais
JOIN paises pd ON cd.id_pais = pd.id_pais
GROUP BY po.nombre, pd.nombre;