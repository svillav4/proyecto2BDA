# Sistema Bancario Internacional Digital

## Integrantes

- Valentina Benítez
- Darieth Sánchez
- Samuel Villa

## Contexto

Sistema bancario internacional digital.

El proyecto simula una infraestructura distribuida donde clientes de varios países usan la plataforma para gestionar cuentas y mover dinero entre países. Cada cliente puede tener una o varias cuentas, cada cuenta tiene una moneda y un país asociado, y el sistema registra cada operación financiera.

---

## Despliegue y configuración en AWS

A

---

## Comparativa entre PostgreSQL y NewSQL

Este apartado corresponde a un primer acercamiento comparativo entre ambas tecnologías.  
Los detalles completos de la implementación y configuración se encuentran en el informe técnico adjunto.

La comparación se realiza sobre los siguientes aspectos:

- Particionamiento  
- Replicación  
- Consistencia y latencia  
- Manejo de transacciones  
- Manejo de fallos  
- Complejidad  

---

## Particionamiento

### PostgreSQL + Citus

La división de los datos se hace usando citus, con este se define la clave de distribución y citus crea y distribuye los shards automáticamente 

Se usa una clave, en este proyecto se diseñó la distribución por rangos de fecha, donde la clave es “transaction_date”, ejemplo:  

Node1 guarda Q1 y Q2 de 2024  

Node2 guarda Q3 y Q4 de 2024  

Node3 guarda 2025+ 

Si se agrega un nodo, se requiere rebalanceo de shards y posible movimiento de datos  

PostgreSQL permite diferentes estrategias como distribución por hash o por clave. 

### YugabyteDB 

El sistema divide la tabla automáticamente, esta partición se basa en la clave primaria 

Crea shards llamados “tablets” a partir de los rangos, esto permite dividir una tabla grande en partes más pequeñas y distribuye los datos entre los diferentes nodos 

Se debe diseñar la clave primaria y si esta incluye la fecha, los datos se agrupan por rangos temporales  

Por último, si un nodo se llena mueve datos (shards) sin intervención basándose en carga y tamaño, es decir, puede dividir dinámicamente. 

## Replicación 

### PostgreSQL + Citus 

La replicación se configura a nivel de nodo usando mecanismos como streaming replication, se puede definir el tipo de replicación entre asíncrona (baja latencia) y síncrona (consistencia fuerte)  

Si falla un nodo, se debe promover una réplica de manera manual o con una herramienta externa. 

### YugabyteDB 

Cada Tablet tiene múltiples réplicas distribuidas en diferentes nodos, es decir, en PostgreSQL es a nivel de nodo, en NewSQL es a nivel de shards. 

Usa consenso tipo Raft para coordinar las réplicas y se elige al líder automáticamente 

Cada escritura se replica en varios nodos y se confirman cuando alcanzan el quorum (si hay 3 replicas, se necesita confirmación de mínimo 2) 

Si falla un nodo, el líder se promueve de manera automática. 

## Consistencia y latencia 

### PostgreSQL + Citus 

Se garantiza ACID cuando la transacción ocurre en solo un nodo 

En varios nodos depende de 2PC, por ejemplo, para transferencias entre cuentas en nodos distintos si hay un fallo después de PREPARE, la transacción queda bloqueada lo que hace que se requiera intervención manual 

Las consultas locales tienen baja latencia, pero las consultas distribuidas requieren comunicación entre nodos, lo que aumenta la latencia debido a la coordinación. 

### YugabyteDB 

El sistema ofrece consistencia fuerte por defecto 

Todas las transacciones son distribuidas y usan consenso para confirmar escritura como se explica en el punto de replicación 

El sistema puede ejecutar consultas en paralelo sobre múltiples shards lo que mejora el rendimiento en consultas grandes 

La latencia base es mayor debido a la replicación y coordinación entre nodos. 

## Manejo de transacciones 

### PostgreSQL + Citus 

Las transacciones locales dentro de un solo shard son simples y mantienen ACID  

Cuando una transacción involucra múltiples nodos, se requiere un protocolo de dos fases (2PC) 

Como se mencionó anteriormente si ocurre un fallo después de PREPARE, la transacción queda en estado pendiente, esto genera bloqueo de recursos y requiere intervención manual para resolver. 

### YugabyteDB 

Las transacciones distribuidas están integradas en el sistema, se gestionan mediante un modelo de consenso donde un nodo líder coordina la operación, esta opreación requiere confirmación de múltiples réplicas antes del commit 

El sistema maneja automáticamente commit y rollback en todos los nodos  

No se exponen estados intermedios ni se requiere lógica adicional en la aplicación. 

## Manejo de fallos 

### PostgreSQL + Citus 

Si un nodo cae, el shard deja de estar disponible temporalmente, y, si no hay replicación se pierde el acceso a los datos, si hay replicación se debe hacer failover manual o configurado.  

Hay riesgo de inconsistencia si se usa una replicación asincróna. 

### YugabyteDB 

Como cada shard tiene múltiples réplicas distribuidas en diferentes nodos, si un nodo cae, otra réplica toma control basado en consenso (y asume rol de líder) por lo que no se detiene el sistema.  

Usa quorum para mantener datos válidos, es decir que si un nodo no es consistente no se toman ni las lecturas ni las escrituras de este. 

## Complejidad 

### PostgreSQL + Citus 

El desarrollador debe definir y configurar aspectos clave como la clave de distribución, estrategia de partición y replicación 

Este enfoque permite mayor control sobre el sistema  

Aumenta la complejidad y la probabilidad de errores debido a la configuración manual. 

### YugabyteDB 

El sistema gestiona automáticamente la distribución, replicación, routing y failover 

La distribución se basa en la clave primaria y se maneja internamente 

Disminuye la complejidad operativa al delegar estas responsabilidades al sistema. 

# Hacia la distribución nativa con NewSQL

**Particionamiento:** El auto-sharding no se activó porque el umbral está configurado en 100 GB, mientras que nuestra carga de datos no supera 1 GB. El motor evita fragmentar tablas pequeñas para optimizar la memoria RAM y procesos internos, manteniendo la eficiencia hasta alcanzar un volumen crítico. Se validó la capacidad de particionamiento mediante un split manual, confirmando que el sistema está listo para escalar horizontalmente.    
<img width="730" height="322" alt="image" src="https://github.com/user-attachments/assets/723fce35-3f72-4f8e-8ad4-f93d5b5c06dc" />
<img width="1092" height="687" alt="image" src="https://github.com/user-attachments/assets/93ca637d-5141-4517-ade5-222c6df86420" />


**Líder de rango (Raft):** Para cada tablet, el factor de replicación se fijó en tres, garantizando alta disponibilidad mediante el protocolo Raft. Esto designa automáticamente un Leader node para procesar escrituras y dos Follower nodes que mantienen copias sincronizadas de los datos. Si el líder falla, el sistema elige uno de los seguidores para retomar la operación sin pérdida de servicio.    
<img width="740" height="290" alt="image" src="https://github.com/user-attachments/assets/6c0b8c3f-28dc-4608-a9f0-8861d3209922" />
<img width="984" height="182" alt="image" src="https://github.com/user-attachments/assets/c6aa00c6-d245-43a3-be36-8f3742968b90" />


**Reto de Geodistribución:** Como no fue posible aplicar latencia directamente, simulamos el fallo de una región apagando el Nodo 3. El sistema detectó la falta de una réplica y pasó a estado 'Under-replicated'. En esta configuración de tres nodos, la caída de uno afecta el quórum necesario para que Raft funcione normalmente. Por ello, el clúster mantuvo las tablets en alerta, priorizando la seguridad de los datos sobre el movimiento de líderes, a la espera de recuperar la conectividad con el nodo remoto.
<img width="1502" height="604" alt="image" src="https://github.com/user-attachments/assets/a717214f-49f2-4641-8dda-ff921d480e82" />



Terminal 1
<img width="1039" height="472" alt="image" src="https://github.com/user-attachments/assets/0b535849-bb62-46d6-ace9-b9846799e6c3" />


Terminal 2
<img width="1030" height="331" alt="image" src="https://github.com/user-attachments/assets/dac801ab-8572-497b-9a91-a32054b1c676" />



| Característica | YugabyteDB (NewSQL) | PostgreSQL Tradicional |
|----------------|---------------------|------------------------|
| **Arquitectura** | Distribuida (Shared-Nothing) | Monolítica (Shared-Everything) |
| **Escalabilidad** | Horizontal (agregar nodos) | Vertical (mejorar hardware) |
| **Tolerancia a particiones (CAP)** | ✅ Sí (CP - Consistency over Availability) | ❌ No (CA - Consistency + Availability) |
| **¿Cómo maneja el particionamiento?** | Detecta automáticamente por heartbeat (8s). Usa líder Raft que mantiene quórum (N/2+1). La subred mayoritaria sigue operando; la minoritaria bloquea escrituras pero permite lecturas stale. | No maneja particionamiento nativo. El sistema completo falla o requiere intervención manual. La replicación es asíncrona o síncrona pero sin detección automática de partición. |
| **¿Cómo se recupera de una partición?** | Automática: re-elección de líder Raft (10-30s). Reconciliación automática por log replication. Failback automático al recuperar nodos. Pérdida de datos: CERO. | Manual: requiere intervención DBA o herramientas externas (Patroni, repmgr). Reconciliación con pg_rewind o re-sync completo. Failover manual (minutos a horas). Posible pérdida de datos si replica asíncrona. |
| **Consistencia por defecto** | Fuerte (linealizable) | Fuerte (ACID) |
| **Latencia con consistencia fuerte** | 20-50ms por operación (entre nodos) | <1ms por operación (misma máquina) |
| **Disponibilidad durante fallo** | Escrituras: pueden bloquearse (si pierde quórum). Lecturas: siempre disponibles. | Completamente no disponible si el maestro falla. |
| **Quórum mínimo** | N/2 + 1 (ej: 2 de 3 nodos) | N/A (1 nodo maestro) |
