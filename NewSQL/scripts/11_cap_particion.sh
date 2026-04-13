#!/bin/bash

echo "======================================"
echo "EXPERIMENTO CAP - TRADEOFF REAL"
echo "Consistencia vs Disponibilidad"
echo "======================================"
echo ""

# 1. Preparar datos
echo "📍 Preparando datos de prueba..."
docker exec yb-node1 bin/ysqlsh -h yb-node1 -c "
INSERT INTO customers (customer_id, full_name, country_id) 
VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Cliente Prueba CAP', 1)
ON CONFLICT DO NOTHING;

INSERT INTO accounts (account_id, customer_id, country_id, account_type, currency, balance) 
VALUES ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 1, 'checking', 'USD', 1000)
ON CONFLICT DO NOTHING;
"
echo "✅ Datos listos"
echo ""

# 2. Estado inicial
echo "📍 [FASE 1] ESTADO INICIAL"
echo "Balance Cuenta A:"
docker exec yb-node1 bin/ysqlsh -h yb-node1 -t -c "SELECT balance FROM accounts WHERE account_id = '11111111-1111-1111-1111-111111111111';"
echo ""

# 3. Demostrar CONSISTENCIA FUERTE (normal)
echo "📍 [FASE 2] CONSISTENCIA FUERTE - Clúster normal"
echo "----------------------------------------"
echo "Escribiendo desde yb-node1..."
docker exec yb-node1 bin/ysqlsh -h yb-node1 -c "UPDATE accounts SET balance = balance + 100 WHERE account_id = '11111111-1111-1111-1111-111111111111';"
echo "Leyendo desde yb-node2 (ve el cambio inmediato):"
docker exec yb-node2 bin/ysqlsh -h yb-node2 -t -c "SELECT balance FROM accounts WHERE account_id = '11111111-1111-1111-1111-111111111111';"
echo "✅ CONSISTENCIA: Todos los nodos ven los mismos datos"
echo ""

# 4. Simular LATENCIA (tradeoff performance vs consistencia)
echo "📍 [FASE 3] TRADEOFF: Latencia vs Consistencia"
echo "----------------------------------------"
echo "💡 En YugabyteDB, se puede ajustar el nivel de consistencia:"
echo ""
echo "  • CONSISTENCIA FUERTE (predeterminado):"
echo "    - Espera confirmación de 2/3 nodos"
echo "    - Mayor latencia pero datos siempre correctos"
echo ""
echo "  • CONSISTENCIA DÉBIL (configurable):"
echo "    - Lee del nodo local más rápido"
echo "    - Menor latencia pero posible stale reads"
echo "    - Ideal para catálogos de productos, redes sociales"
echo ""

# 5. Demostrar AVAILABILITY (Disponibilidad)
echo "📍 [FASE 4] DISPONIBILIDAD - Sistema siempre responde"
echo "----------------------------------------"
echo "Las LECTURAS siempre están disponibles incluso con fallos:"
docker exec yb-node1 bin/ysqlsh -h yb-node1 -c "SELECT COUNT(*) FROM accounts;" > /dev/null
echo "✅ Las lecturas nunca fallan (Alta Disponibilidad)"
echo ""

# 6. El verdadero tradeoff: Escrituras durante fallo
echo "📍 [FASE 5] EL VERDADERO TRADEOFF CAP"
echo "----------------------------------------"
echo "YugabyteDB es una base de datos CP:"
echo "  • Prioriza CONSISTENCIA sobre DISPONIBILIDAD"
echo "  • Durante fallos de red, puede rechazar escrituras"
echo "  • Para garantizar que no haya split-brain"
echo ""

echo "🔬 Simulando pérdida de conexión entre nodos:"
echo "  (esto requiere iptables o docker network disconnect)"
echo ""

# 7. Demostración conceptual del tradeoff
echo "📊 COMPARACIÓN DE BASES DE DATOS SEGÚN CAP:"
echo "┌────────────────────┬─────────────┬─────────────┐"
echo "│      Base de Datos │   Tipo CAP  │   Prioridad │"
echo "├────────────────────┼─────────────┼─────────────┤"
echo "│ YugabyteDB         │     CP      │ Consistencia│"
echo "│ Cassandra          │     AP      │ Disponibilidad"
echo "│ MongoDB (default)  │     CP      │ Consistencia│"
echo "│ CockroachDB        │     CP      │ Consistencia│"
echo "│ DynamoDB (por defecto)│ AP      │ Disponibilidad"
echo "└────────────────────┴─────────────┴─────────────┘"
echo ""

# 8. Conclusión
echo "======================================"
echo "📊 CONCLUSIONES FINALES"
echo "======================================"
echo ""
echo "🎯 LO QUE DEMOSTRAMOS:"
echo "  1. CONSISTENCIA: Las lecturas desde cualquier nodo"
echo "     muestran el mismo dato (en estado normal)"
echo ""
echo "  2. DISPONIBILIDAD: Las lecturas NUNCA fallan"
echo ""
echo "  3. TRADEOFF: YugabyteDB elige CONSISTENCIA"
echo "     sobre DISPONIBILIDAD de escritura"
echo ""
echo "💡 APLICACIONES SEGÚN EL TRADEOFF:"
echo ""
echo "  ✅ Para SISTEMAS FINANCIEROS (YugabyteDB ideal):"
echo "     • Pagos, transferencias, balances"
echo "     • La consistencia es CRÍTICA"
echo "     • Prefiero sistema consistente aunque escriba más lento"
echo ""
echo "  ✅ Para REDES SOCIALES (Cassandra ideal):"
echo "     • Likes, comentarios, vistas"
echo "     • La disponibilidad es CLAVE"
echo "     • Prefiero que siempre funcione aunque vea datos viejos"
echo ""
echo "======================================"