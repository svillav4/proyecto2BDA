-- 04_tolerancia_fallos.sql
-- Demostración de tolerancia a fallos - VERSIÓN AUTOMÁTICA

\echo '=== DEMOSTRACIÓN DE TOLERANCIA A FALLOS ==='
\echo ''

\echo '1. Verificando estado ANTES del fallo:'
SELECT COUNT(*) as total_accounts, SUM(balance) as total_balance FROM accounts;

\echo ''
\echo '2. Cuentas de prueba:'
SELECT account_id, balance FROM accounts LIMIT 3;

\echo ''
\echo '3. Insertando datos de prueba...'
INSERT INTO accounts (account_id, customer_id, country_id, account_type, currency, balance) 
VALUES ('99999999-9999-9999-9999-999999999999', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 1, 'checking', 'USD', 5000)
ON CONFLICT (account_id) DO NOTHING;

\echo '✅ Datos insertados correctamente'
\echo ''
\echo '=== AHORA DETIENE EL NODO 2 EN OTRA TERMINAL ==='
\echo 'Ejecuta: docker stop yb-node2'
\echo 'Luego ejecuta: docker exec -i yb-node1 bin/ysqlsh -h yb-node1 < scripts/05_despues_del_fallo.sql'