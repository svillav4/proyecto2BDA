#!/bin/bash

echo "======================================"
echo "EXPERIMENTO: LATENCIA EN YUGABYTEDB"
echo "======================================"
echo ""

# Verificar que el clúster está respondiendo
echo "📍 Verificando conectividad..."
if ! docker exec yb-node1 bin/ysqlsh -h yb-node1 -c "SELECT 1;" > /dev/null 2>&1; then
    echo "❌ Error: Clúster no responde"
    echo "Ejecuta: docker compose restart"
    exit 1
fi
echo "✅ Clúster conectado"
echo ""

# Medir latencia de lectura (simple)
echo "📊 LATENCIA DE LECTURA (10 consultas):"
INICIO=$(date +%s%N)
for i in {1..10}; do
    docker exec yb-node1 bin/ysqlsh -h yb-node1 -t -c "SELECT balance FROM accounts LIMIT 1;" > /dev/null 2>&1
done
FIN=$(date +%s%N)
DURACION=$(( ($FIN - $INICIO) / 1000000 ))
echo "   Tiempo total: ${DURACION} ms"
echo "   Promedio: $(( DURACION / 10 )) ms por consulta"
echo ""

# Medir latencia de escritura
echo "✏️  LATENCIA DE ESCRITURA (10 actualizaciones):"
INICIO=$(date +%s%N)
for i in {1..10}; do
    docker exec yb-node1 bin/ysqlsh -h yb-node1 -c "UPDATE accounts SET balance = balance + 1 WHERE account_id = '11111111-1111-1111-1111-111111111111';" > /dev/null 2>&1
done
FIN=$(date +%s%N)
DURACION=$(( ($FIN - $INICIO) / 1000000 ))
echo "   Tiempo total: ${DURACION} ms"
echo "   Promedio: $(( DURACION / 10 )) ms por escritura"
echo ""

echo "======================================"
echo "✅ Experimento completado"
echo "======================================"