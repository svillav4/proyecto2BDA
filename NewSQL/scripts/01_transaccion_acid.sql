-- 01_transaccion_acid.sql
-- Demostración de Atomicidad y Consistencia en transacciones distribuidas

-- Limpiar datos previos de prueba
DO $$
BEGIN
    -- Limpiar transacciones de prueba
    DELETE FROM transactions WHERE transaction_type = 'transfer_test';
    
    -- Restaurar balances originales (1000, 2000, 3000)
    UPDATE accounts SET balance = 1000.00 WHERE account_id = '11111111-1111-1111-1111-111111111111';
    UPDATE accounts SET balance = 2000.00 WHERE account_id = '22222222-2222-2222-2222-222222222222';
    UPDATE accounts SET balance = 3000.00 WHERE account_id = '33333333-3333-3333-3333-333333333333';
END $$;

-- Verificar estado inicial
\echo '=== ESTADO INICIAL ==='
SELECT account_id, balance FROM accounts 
WHERE account_id IN ('11111111-1111-1111-1111-111111111111', 
                     '22222222-2222-2222-2222-222222222222');

\echo '=== INICIANDO TRANSFERENCIA DISTRIBUIDA (TRANSACCIÓN ACID) ==='
\echo 'Transferencia de $100 de Cuenta A a Cuenta B'

-- Transacción ACID completa (todo o nada)
BEGIN;

    -- Verificar saldo origen
    SELECT account_id, balance FROM accounts 
    WHERE account_id = '11111111-1111-1111-1111-111111111111';
    
    -- Debita de origen
    UPDATE accounts 
    SET balance = balance - 100 
    WHERE account_id = '11111111-1111-1111-1111-111111111111';
    
    -- Acredita a destino
    UPDATE accounts 
    SET balance = balance + 100 
    WHERE account_id = '22222222-2222-2222-2222-222222222222';
    
    -- Registrar la transacción
    INSERT INTO transactions (
        transaction_id, 
        source_account_id, 
        destination_account_id, 
        amount, 
        currency, 
        transaction_type
    ) VALUES (
        gen_random_uuid(),
        '11111111-1111-1111-1111-111111111111',
        '22222222-2222-2222-2222-222222222222',
        100,
        'USD',
        'transfer_test'
    );

COMMIT;

\echo '=== ESTADO FINAL DESPUÉS DE LA TRANSFERENCIA ==='
SELECT account_id, balance FROM accounts 
WHERE account_id IN ('11111111-1111-1111-1111-111111111111', 
                     '22222222-2222-2222-2222-222222222222');

\echo '=== REGISTRO DE LA TRANSACCIÓN ==='
SELECT transaction_id, 
       source_account_id, 
       destination_account_id, 
       amount, 
       transaction_type, 
       transaction_date 
FROM transactions 
WHERE transaction_type = 'transfer_test'
ORDER BY transaction_date DESC
LIMIT 1;

\echo '=== VERIFICACIÓN DE CONSISTENCIA ==='
\echo 'Suma total de balances (debería mantenerse constante):'
SELECT SUM(balance) as total_balance FROM accounts 
WHERE account_id IN ('11111111-1111-1111-1111-111111111111', 
                     '22222222-2222-2222-2222-222222222222');