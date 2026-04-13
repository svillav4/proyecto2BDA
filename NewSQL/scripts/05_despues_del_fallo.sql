-- 05_despues_del_fallo.sql
-- Ejecutar DESPUÉS de detener yb-node2 - VERSIÓN AUTOMÁTICA

\echo '=== CLÚSTER FUNCIONANDO CON UN NODO CAÍDO ==='

\echo ''
\echo '1. Consultando datos existentes (debería funcionar):'
SELECT COUNT(*) as total_accounts FROM accounts;

\echo ''
\echo '2. Realizando operación de escritura (debería funcionar):'
UPDATE accounts 
SET balance = balance + 100 
WHERE account_id = '11111111-1111-1111-1111-111111111111';

\echo '✅ Actualización completada'

\echo ''
\echo '3. Verificando la actualización:'
SELECT account_id, balance 
FROM accounts 
WHERE account_id = '11111111-1111-1111-1111-111111111111';

\echo ''
\echo '4. Insertando nueva transacción durante el fallo:'
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
    75,
    'USD',
    'during_failure_test'
);

\echo '✅ Transacción insertada correctamente DURANTE el fallo'

\echo ''
\echo '5. Verificando la transacción:'
SELECT transaction_id, amount, transaction_type, transaction_date 
FROM transactions 
WHERE transaction_type = 'during_failure_test'
ORDER BY transaction_date DESC
LIMIT 1;

\echo ''
\echo '=== EL CLÚSTER SIGUE FUNCIONANDO A PESAR DEL FALLO ==='
\echo 'Ahora recupera el nodo: docker start yb-node2'
\echo 'Luego ejecuta: docker exec -i yb-node1 bin/ysqlsh -h yb-node1 < scripts/06_recuperacion_failback.sql'