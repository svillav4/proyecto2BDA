-- 02_aislamiento_terminal1.sql
-- Primera sesión: Lectura con nivel REPEATABLE READ
-- Ejecutar desde TERMINAL 1

\echo '=== TERMINAL 1: Iniciando transacción con nivel REPEATABLE READ ==='
\echo 'Esta transacción leerá el saldo de la Cuenta A y lo mantendrá consistente'
\echo ''

BEGIN ISOLATION LEVEL REPEATABLE READ;

    \echo 'Leyendo saldo de la Cuenta A...'
    SELECT account_id, balance, current_timestamp as read_at 
    FROM accounts 
    WHERE account_id = '11111111-1111-1111-1111-111111111111';
    
    \echo ''
    \echo '=== TRANSACCIÓN ACTIVA ==='
    \echo 'La transacción está abierta con nivel REPEATABLE READ'
    \echo 'La cuenta está "protegida" contra modificaciones concurrentes'
    \echo ''
    \echo 'Presiona Ctrl+C para salir, luego ejecuta: COMMIT;'
    \echo '=================================='
    
    -- Mantener la transacción abierta
    \watch 1