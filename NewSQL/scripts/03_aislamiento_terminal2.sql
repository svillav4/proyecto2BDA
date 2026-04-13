-- 03_aislamiento_terminal2.sql
-- Segunda sesión: Intento de modificación mientras Terminal 1 tiene bloqueo
-- EJECUTAR ESTO EN LA TERMINAL 2 (MIENTRAS Terminal 1 está en ejecución)

\echo '=== TERMINAL 2: Intentando modificar la misma cuenta ==='
\echo 'Esta operación QUEDARÁ EN ESPERA hasta que Terminal 1 haga COMMIT'
\echo 'Esto demuestra el AISLAMIENTO - las transacciones no interfieren'

\echo 'Intentando actualizar Cuenta A...'
UPDATE accounts 
SET balance = balance - 50 
WHERE account_id = '11111111-1111-1111-1111-111111111111';

\echo 'Actualización completada (esto solo aparece después que Terminal 1 hace COMMIT)'

-- Verificar resultado final
\echo '=== RESULTADO FINAL ==='
SELECT account_id, balance FROM accounts 
WHERE account_id = '11111111-1111-1111-1111-111111111111';