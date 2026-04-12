**Particionamiento:** El auto-sharding no se activó porque el umbral está configurado en 100 GB, mientras que nuestra carga de datos no supera 1 GB. El motor evita fragmentar tablas pequeñas para optimizar la memoria RAM y procesos internos, manteniendo la eficiencia hasta alcanzar un volumen crítico. Se validó la capacidad de particionamiento mediante un split manual, confirmando que el sistema está listo para escalar horizontalmente.    
<img width="730" height="322" alt="image" src="https://github.com/user-attachments/assets/723fce35-3f72-4f8e-8ad4-f93d5b5c06dc" />
<img width="1092" height="687" alt="image" src="https://github.com/user-attachments/assets/93ca637d-5141-4517-ade5-222c6df86420" />


**Líder de rango (Raft):** Para cada tablet, el factor de replicación se fijó en tres, garantizando alta disponibilidad mediante el protocolo Raft. Esto designa automáticamente un Leader node para procesar escrituras y dos Follower nodes que mantienen copias sincronizadas de los datos. Si el líder falla, el sistema elige uno de los seguidores para retomar la operación sin pérdida de servicio.    
<img width="740" height="290" alt="image" src="https://github.com/user-attachments/assets/6c0b8c3f-28dc-4608-a9f0-8861d3209922" />
<img width="984" height="182" alt="image" src="https://github.com/user-attachments/assets/c6aa00c6-d245-43a3-be36-8f3742968b90" />

