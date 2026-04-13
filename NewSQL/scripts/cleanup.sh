#!/bin/bash

set -e

echo "=========================================="
echo "              Limpiar NewSQL"
echo "=========================================="

echo "Detener y eliminar contenedores, y eliminar volumen"
docker-compose down -v

echo "Eliminar carpetas de la persistencia de datos"
rm -rf ./yb_data

echo "Eliminar red"
docker network rm yb-lab-net 2>/dev/null || true

echo "Limpieza completada"
echo "Para inicializar nuevamente, ejecutar ./scripts/setup.sh"