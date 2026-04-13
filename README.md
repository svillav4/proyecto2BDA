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



