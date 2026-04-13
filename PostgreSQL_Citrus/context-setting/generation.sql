---Generar países.

INSERT INTO paises (nombre, codigo_iso)
VALUES
('Colombia','CO'),
('Estados Unidos','US'),
('España','ES'),
('México','MX'),
('Brasil','BR'),
('Argentina','ARG');

---Generar clientes.

INSERT INTO clientes (id_cliente, nombre, pais_residencia, fecha_registro)
SELECT
gs AS id_cliente,
'cliente_' || gs,
(1 + random()*5)::int,
NOW() - (random()*1000) * INTERVAL '1 day'
FROM generate_series(1,100000) gs;

---Generar cuentas.

INSERT INTO cuentas (id_cliente, id_pais, moneda, saldo, fecha_creacion)
SELECT
(1 + random()*99999)::int,
(1 + random()*4)::int,
CASE
WHEN random() < 0.15 THEN 'COP'
WHEN random() < 0.30 THEN 'USD'
WHEN random() < 0.45 THEN 'EUR'
WHEN random() < 0.60 THEN 'MXN'
WHEN random() < 0.75 THEN 'BRL'
WHEN random() < 0.90 THEN 'ARS'
ELSE 'USD'
END,
random()*100000,
NOW() - (random()*1000) * INTERVAL '1 day'
FROM generate_series(1,300000);

---Generar transacciones.

INSERT INTO transacciones (
cuenta_origen,
cuenta_destino,
monto,
moneda,
fecha_transaccion,
tipo_transaccion
)
SELECT
(1 + random()*299999)::int,
(1 + random()*299999)::int,
random()*1000,
CASE
WHEN random() < 0.15 THEN 'COP'
WHEN random() < 0.30 THEN 'USD'
WHEN random() < 0.45 THEN 'EUR'
WHEN random() < 0.60 THEN 'MXN'
WHEN random() < 0.75 THEN 'BRL'
WHEN random() < 0.90 THEN 'ARS'
ELSE 'USD'
END,
NOW() - (random()*365) * INTERVAL '1 day',
CASE
WHEN random() < 0.6 THEN 'transferencia'
WHEN random() < 0.8 THEN 'pago'
ELSE 'deposito'
END
FROM generate_series(1,10000000);