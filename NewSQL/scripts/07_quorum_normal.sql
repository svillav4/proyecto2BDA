\echo '=== QUÓRUM NORMAL: CONSISTENCIA FUERTE (READ QUORUM) ==='
\echo ''

-- Estado inicial
SELECT account_id, balance FROM accounts 
WHERE account_id = '11111111-1111-1111-1111-111111111111';

-- Escribir con QUORUM (siempre es así)
UPDATE accounts SET balance = balance + 100 
WHERE account_id = '11111111-1111-1111-1111-111111111111';

\echo 'Escritura completada (requirió 2/3 nodos)'

-- Leer con QUORUM (por defecto)
SELECT account_id, balance FROM accounts 
WHERE account_id = '11111111-1111-1111-1111-111111111111';

\echo '✅ Lectura QUORUM: ve el valor más reciente'