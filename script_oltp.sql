--- Crear cuenta

INSERT INTO cuentas (id_cliente,id_pais,moneda,saldo,fecha_creacion)
VALUES (25,1,'USD',500,NOW());

--- Consultar saldo

SELECT saldo
FROM cuentas
WHERE id_cuenta = 1050;

--- Transferencia entre cuentas

BEGIN;

UPDATE cuentas
SET saldo = saldo - 200
WHERE id_cuenta = 100;

UPDATE cuentas
SET saldo = saldo + 200
WHERE id_cuenta = 200;

INSERT INTO transacciones (
cuenta_origen,
cuenta_destino,
monto,
moneda,
fecha_transaccion,
tipo_transaccion
)
VALUES (100,200,200,'USD',NOW(),'transferencia');

COMMIT;

--- Registrar pago

INSERT INTO transacciones
(cuenta_origen,cuenta_destino,monto,moneda,fecha_transaccion,tipo_transaccion)
VALUES
(100,500,50,'USD',NOW(),'pago');