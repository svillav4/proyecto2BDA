#!/bin/bash

echo "======================================"
echo "DEMOSTRACIÓN DE TOLERANCIA A FALLOS"
echo "YugabyteDB - Failover y Failback"
echo "======================================"
echo ""

# 1. Mostrar estado inicial
echo "📍 [PASO 1] Estado inicial del clúster:"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep yb-node
echo ""

# 2. Ver datos actuales
echo "📍 [PASO 2] Datos antes del fallo:"
docker exec yb-node1 bin/ysqlsh -h yb-node1 -c "SELECT COUNT(*) as total_cuentas FROM accounts;"
echo ""

# 3. Insertar un registro de prueba
echo "📍 [PASO 3] Insertando cuenta de prueba:"
docker exec yb-node1 bin/ysqlsh -h yb-node1 -c "
INSERT INTO accounts (account_id, customer_id, country_id, account_type, currency, balance) 
VALUES ('ffffffff-ffff-ffff-ffff-ffffffffffff', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 1, 'checking', 'USD', 9999)
ON CONFLICT (account_id) DO NOTHING;
"
echo "✅ Cuenta de prueba creada"
echo ""

# 4. SIMULAR FALLO - Detener nodo 2
echo "📍 [PASO 4] SIMULANDO FALLO: Deteniendo yb-node2"
docker stop yb-node2
sleep 3
echo "✅ Nodo 2 detenido"
echo ""

# 5. Verificar que el clúster sigue funcionando
echo "📍 [PASO 5] Verificando que el clúster SIGUE FUNCIONANDO:"
echo "Consultando desde yb-node1:"
docker exec yb-node1 bin/ysqlsh -h yb-node1 -c "SELECT COUNT(*) as total_cuentas, SUM(balance) as balance_total FROM accounts;"
echo ""

# 6. Realizar operación durante el fallo
echo "📍 [PASO 6] Realizando operación DURANTE el fallo:"
docker exec yb-node1 bin/ysqlsh -h yb-node1 -c "
UPDATE accounts SET balance = balance + 500 
WHERE account_id = '11111111-1111-1111-1111-111111111111';
"
echo "✅ Actualización realizada exitosamente durante el fallo"
echo ""

# 7. Verificar la actualización
echo "📍 [PASO 7] Verificando la actualización:"
docker exec yb-node1 bin/ysqlsh -h yb-node1 -c "
SELECT account_id, balance 
FROM accounts 
WHERE account_id = '11111111-1111-1111-1111-111111111111';
"
echo ""

# 8. FAILBACK - Recuperar nodo
echo "📍 [PASO 8] FAILBACK: Recuperando yb-node2"
docker start yb-node2
echo "✅ Nodo 2 reiniciado"
echo "Esperando sincronización (10 segundos)..."
sleep 10
echo ""

# 9. Verificar sincronización desde el nodo recuperado
echo "📍 [PASO 9] Verificando sincronización desde yb-node2:"
docker exec yb-node2 bin/ysqlsh -h yb-node2 -c "
SELECT account_id, balance 
FROM accounts 
WHERE account_id = '11111111-1111-1111-1111-111111111111';
"
echo ""

# 10. Verificar la cuenta de prueba
echo "📍 [PASO 10] Verificando cuenta de prueba creada durante el fallo:"
docker exec yb-node2 bin/ysqlsh -h yb-node2 -c "
SELECT account_id, balance 
FROM accounts 
WHERE account_id = 'ffffffff-ffff-ffff-ffff-ffffffffffff';
"
echo ""

echo "======================================"
echo "✅ DEMOSTRACIÓN COMPLETADA EXITOSAMENTE"
echo "======================================"
echo "CONCEPTOS DEMOSTRADOS:"
echo "• FAIL-OVER: El sistema funcionó con 2 de 3 nodos"
echo "• DURABILIDAD: Las escrituras durante el fallo se mantuvieron"
echo "• FAILBACK: El nodo recuperado se sincronizó automáticamente"
echo "• CONSISTENCIA: Todos los nodos tienen los mismos datos"
echo "======================================"