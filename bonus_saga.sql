---Flujo 2PC

BEGIN;

UPDATE cuentas
SET saldo = saldo - 200
WHERE id_cuenta = 100;

UPDATE cuentas
SET saldo = saldo + 200
WHERE id_cuenta = 200;

PREPARE TRANSACTION 'tx1';

COMMIT PREPARED 'tx1';

--- Flujo SAGA

--- Paso 1
UPDATE cuentas
SET saldo = saldo - 200
WHERE id_cuenta = 100;

--- Paso 2
UPDATE cuentas
SET saldo = saldo + 200
WHERE id_cuenta = 200;

--- Paso 3 sin errores
INSERT INTO transacciones (
    cuenta_origen,
    cuenta_destino,
    monto,
    moneda,
    fecha_transaccion,
    tipo_transaccion
)
VALUES (
    100,
    200,
    200,
    'USD',
    NOW(),
    'transferencia'
);

--- Paso 3 con errores
UPDATE cuentas
SET saldo = saldo + 200
WHERE id_cuenta = 100;