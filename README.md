# Sistema Bancario Internacional Digital

## Integrantes

- Valentina Benítez
- Darieth Sánchez
- Samuel Villa

## Contexto

Sistema bancario internacional digital.

El proyecto simula una infraestructura distribuida donde clientes de varios países usan la plataforma para gestionar cuentas y mover dinero entre países. Cada cliente puede tener una o varias cuentas, cada cuenta tiene una moneda y un país asociado, y el sistema registra cada operación financiera.

---

## Ejecución y entorno

La ejecución del proyecto se realizó mediante Docker y Docker Compose, herramientas que facilitaron la creación de un entorno aislado y controlado. Gracias a esto, se logró simular una infraestructura de red donde coexisten múltiples servicios (bases de datos, brokers de mensajería y microservicios)

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


# NewSQL 
## Arquitectura YugabyteDB
<img width="1220" height="1240" alt="on-premiseBDA" src="https://github.com/user-attachments/assets/82d78c62-e71a-4ce3-ba33-2c930bdc2bc6" />
<img width="2120" height="960" alt="containerBDA" src="https://github.com/user-attachments/assets/08876d2b-a552-4917-889a-4adb04ccab5d" />
<img width="1062" height="762" alt="tabletBDA" src="https://github.com/user-attachments/assets/1fe17698-ef93-4edd-913d-2b1d87d5aaf3" />



