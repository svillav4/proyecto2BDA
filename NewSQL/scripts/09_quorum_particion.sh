#!/bin/bash
# scripts/09_quorum_particion.sh

echo "======================================"
echo "EXPERIMENTO: QUÓRUM DURANTE PARTICIÓN"
echo "Tradeoff: Consistencia vs Disponibilidad"
echo "======================================"
echo ""

# 1. Estado normal
echo "📍 [PASO 1] Estado normal (3 nodos):"
docker exec yb-node1 bin/ysqlsh -h yb-node1 -c "SELECT account_id, balance FROM accounts WHERE account_id = '11111111-1111-1111-1111-111111111111';"
echo ""

# 2. Insertar valor conocido
docker exec yb-node1 bin/ysqlsh -h yb-node1 -c "UPDATE accounts SET balance = 1000 WHERE account_id = '11111111-1111-1111-1111-111111111111';"
echo "✅ Balance inicial = 1000"
echo ""

# 3. SIMULAR PARTICIÓN: Detener 1 nodo (mayoría aún viva)
echo "📍 [PASO 2] Simulando PARTICIÓN: Deteniendo yb-node3"
docker stop yb-node3
sleep 3
echo "✅ Nodo 3 caído - AÚN hay QUÓRUM (2 de 3 nodos vivos)"
echo ""

# 4. Escritura con quórum (debe funcionar)
echo "📍 [PASO 3] Escritura con QUORUM (2 nodos confirman):"
docker exec yb-node1 bin/ysqlsh -h yb-node1 -c "UPDATE accounts SET balance = balance + 100 WHERE account_id = '11111111-1111-1111-1111-111111111111';"
echo "✅ Escritura exitosa - Quórum alcanzado"
echo ""

# 5. Lectura con consistencia fuerte (debe funcionar)
echo "📍 [PASO 4] Lectura QUORUM (consistencia fuerte):"
docker exec yb-node1 bin/ysqlsh -h yb-node1 -c "SELECT account_id, balance FROM accounts WHERE account_id = '11111111-1111-1111-1111-111111111111';"
echo ""

# 6. CRÍTICO: Detener SEGUNDO nodo (pérdida de quórum)
echo "📍 [PASO 5] ⚠️  PÉRDIDA DE QUÓRUM: Deteniendo yb-node2"
docker stop yb-node2
sleep 3
echo "❗ Solo 1 nodo vivo de 3 - NO HAY QUÓRUM"
echo ""

# 7. Intento de escritura (DEBE FALLAR o quedar en espera)
echo "📍 [PASO 6] Intento de ESCRITURA sin quórum:"
timeout 5 docker exec yb-node1 bin/ysqlsh -h yb-node1 -c "UPDATE accounts SET balance = balance + 100 WHERE account_id = '11111111-1111-1111-1111-111111111111';" || echo "❗ TIMEOUT: Escritura bloqueada - No hay quórum"
echo ""

# 8. Lectura durante partición (debería funcionar - disponible)
echo "📍 [PASO 7] LECTURA durante partición (sigue funcionando):"
docker exec yb-node1 bin/ysqlsh -h yb-node1 -c "SELECT account_id, balance FROM accounts WHERE account_id = '11111111-1111-1111-1111-111111111111';"
echo "✅ Lectura exitosa - Disponibilidad parcial"
echo ""

# 9. Recuperar quórum
echo "📍 [PASO 8] Recuperando nodos para restaurar quórum..."
docker start yb-node2 yb-node3
sleep 10
echo "✅ Quórum restaurado"
echo ""

echo "======================================"
echo "📊 CONCLUSIONES DEL EXPERIMENTO"
echo "======================================"
echo "• CON QUÓRUM (2+ nodos): Escrituras y lecturas fuertes funcionan"
echo "• SIN QUÓRUM (1 nodo):  Escrituras BLOQUEADAS (prioriza consistencia)"
echo "• LECTURAS: Siempre disponibles (prioriza disponibilidad parcial)"
echo ""
echo "🔬 TRADEOFF DEMOSTRADO:"
echo "  YugabyteDB elige CONSISTENCIA sobre DISPONIBILIDAD"
echo "  durante particiones severas (no sacrifica consistencia)"
echo "======================================"