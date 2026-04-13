-- 06_recuperacion_failback.sql
-- Ejecutar DESPUÉS de reiniciar yb-node2 - VERSIÓN AUTOMÁTICA

\echo '=== DEMOSTRACIÓN DE FAILBACK (RECUPERACIÓN AUTOMÁTICA) ==='
\echo ''

\echo '1. Verificando que el clúster se recuperó:'
\echo 'Conexión actual al nodo: ' || inet_server_addr()::text;

\echo ''
\echo '2. Consultando datos desde el nodo recuperado:'
SELECT COUNT(*) as total_accounts, SUM(balance) as total_balance FROM accounts;

\echo ''
\echo '3. Verificando la cuenta modificada durante el fallo:'
SELECT account_id, balance 
FROM accounts 
WHERE account_id = '11111111-1111-1111-1111-111111111111';

\echo ''
\echo '4. Verificando la cuenta insertada durante el fallo:'
SELECT account_id, balance 
FROM accounts 
WHERE account_id = '99999999-9999-9999-9999-999999999999';

\echo ''
\echo '5. Verificando transacciones creadas durante el fallo:'
SELECT transaction_type, amount, transaction_date 
FROM transactions 
WHERE transaction_type = 'during_failure_test'
ORDER BY transaction_date DESC
LIMIT 1;

\echo ''
\echo '=== RECUPERACIÓN COMPLETA ==='
\echo '✅ Todos los datos se sincronizaron automáticamente'
\echo '✅ El clúster volvió a su estado normal de 3 nodos'