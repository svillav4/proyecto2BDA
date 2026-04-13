\echo '=== TRADEOFF: LECTURAS CON CONSISTENCIA ONE ==='
\echo 'Permite menor latencia a costa de posible stale reads'
\echo ''

-- Forzar lectura desde UN SOLO nodo (el más cercano)
-- Nota: En YSQL no hay sintaxis directa, se configura en driver/cliente
\echo 'En YugabyteDB, las lecturas ONE son ideales para:'
\echo '- Reportes que toleran datos ligeramente desactualizados'
\echo '- Aplicaciones con alta demanda de lectura'
\echo '- Reducción de latencia en regiones remotas'
\echo ''

-- Verificar que el dato existe (independientemente de consistencia)
SELECT account_id, balance FROM accounts 
WHERE account_id = '11111111-1111-1111-1111-111111111111';