#!/bin/bash

set -e  # Detener si hay error

echo "==========================================="
echo "4.2 Hacia la distribución nativa con NewSQL"
echo "==========================================="

# 1. Carpetas para la persistencia 
echo -e "\n[1/5] Crear carpetas para cada nodo en yb_data"
mkdir -p ./yb_data/node1
mkdir -p ./yb_data/node2
mkdir -p ./yb_data/node3
echo -e "Carpetas creadas"

# 2. Docker y Docker Compose
echo -e "\n[2/5] Verificar que Docker y Docker Compose están instalados"
if ! command -v docker &> /dev/null; then
    echo -e "Docker no está instalado"
    exit 1
fi
if ! docker compose version &> /dev/null; then
    echo -e "Docker Compose no está instalado"
    exit 1
fi
echo -e "Docker y Docker Compose están instalados"

# 3. Detener y eliminar contenedores, y eliminar la red
echo -e "\n[3/5] Limpiar entorno de ejecuciones previas"
docker stop yb-node1 yb-node2 yb-node3 2>/dev/null || true
docker rm yb-node1 yb-node2 yb-node3 2>/dev/null || true
docker network rm yb-network 2>/dev/null || true
echo -e "Limpieza completada"

# 4. Descargar la imagen
echo -e "\n[4/5] Descargar la imagen de YugabyteDB"
docker pull yugabytedb/yugabyte:latest
echo -e "Imagen descargada"

# 5. Levantar el clúster con docker compose
echo -e "\n[5/5] Levantar el clúster"
docker compose up -d
echo -e "Clúster levantado"

# Esperar a que los nodos estén saludables
echo -e "\nEsperar a que los nodos estén disponibles"
sleep 30

# Verificar estado
echo -e "\nVerificar estado del clúster:"
docker compose ps

echo "==========================================="
echo -e "UI Web: http://localhost:15433"
echo -e "Conectar a Nodo 1: docker exec -it yb-node1 bin/ysqlsh -h yb-node1"
echo -e "Conectar a Nodo 2: docker exec -it yb-node2 bin/ysqlsh -h yb-node2"
echo -e "Conectar a Nodo 3: docker exec -it yb-node3 bin/ysqlsh -h yb-node3"
echo -e "Conectar al clúster: psql -h localhost -p 5433 -U yugabyte"
echo -e "Detener el clúster: docker compose down"
echo -e "Eliminar el clúster: docker compose down -v"
echo "==========================================="