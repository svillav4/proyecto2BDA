#!/bin/bash

# 00_demo_completa.sh
# Script principal para ejecutar la demostración completa

echo "======================================"
echo "LABORATORIO YUGABYTEDB - DEMOSTRACIÓN"
echo "Transacciones Distribuidas y Tolerancia a Fallos"
echo "======================================"
echo ""

# Verificar que los contenedores están corriendo
echo "Verificando estado de los contenedores..."
if ! docker ps | grep -q yb-node; then
    echo "ERROR: Los contenedores no están corriendo"
    echo "Ejecuta: docker compose up -d"
    exit 1
fi

echo ""
echo "=== PARTE 1: TRANSACCIONES ACID ==="
echo "Demostrando Atomicidad y Consistencia..."
docker exec -i yb-node1 bin/ysqlsh -h yb-node1 -U yugabyte -d yugabyte < scripts/01_transaccion_acid.sql

echo ""
echo "=== PARTE 2: AISLAMIENTO (CONCURRENCIA) ==="
echo "Demostrando aislamiento de transacciones..."
echo ""
echo "INSTRUCCIONES:"
echo "1. Abre UNA NUEVA TERMINAL y ejecuta: docker exec -it yb-node1 bin/ysqlsh -h yb-node1"
echo "2. En esa terminal, ejecuta: \\i scripts/02_aislamiento_terminal1.sql"
echo "3. En ESTA terminal, ejecuta: docker exec -it yb-node1 bin/ysqlsh -h yb-node1 -f scripts/03_aislamiento_terminal2.sql"
echo ""
read -p "Presiona ENTER cuando hayas completado la demostración de aislamiento..."

echo ""
echo "=== PARTE 3: TOLERANCIA A FALLOS ==="
echo "Demostrando fail-over..."
echo ""
echo "Paso 1 - Estado normal:"
docker exec -i yb-node1 bin/ysqlsh -h yb-node1 -U yugabyte -d yugabyte < scripts/04_tolerancia_fallos.sql

echo ""
echo "Paso 2 - Simulando fallo del nodo 2..."
read -p "Presiona ENTER para detener yb-node2..."
docker stop yb-node2
echo "✅ Nodo 2 detenido - fallo simulado"
sleep 3

echo ""
echo "Paso 3 - Verificando que el clúster sigue funcionando:"
docker exec -i yb-node1 bin/ysqlsh -h yb-node1 -U yugabyte -d yugabyte < scripts/05_despues_del_fallo.sql

echo ""
echo "Paso 4 - Recuperando el nodo (failback)..."
read -p "Presiona ENTER para reiniciar yb-node2..."
docker start yb-node2
echo "✅ Nodo 2 reiniciado - esperando sincronización..."
sleep 10

echo ""
echo "Paso 5 - Verificando recuperación:"
docker exec -i yb-node1 bin/ysqlsh -h yb-node1 -U yugabyte -d yugabyte < scripts/06_recuperacion_failback.sql

echo ""
echo "======================================"
echo "DEMOSTRACIÓN COMPLETADA EXITOSAMENTE"
echo "======================================"
echo "Conceptos demostrados:"
echo "✅ Atomicidad - Transacción todo o nada"
echo "✅ Consistencia - Reglas de negocio mantenidas"
echo "✅ Aislamiento - Transacciones concurrentes no interfieren"
echo "✅ Durabilidad - Datos persistentes ante fallos"
echo "✅ Fail-over - Clúster funciona con nodo caído"
echo "✅ Failback - Recuperación automática al reiniciar nodo"
echo "======================================"