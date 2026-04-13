SELECT citus_add_node('citus_worker1', 5432);
SELECT citus_add_node('citus_worker2', 5432);

CREATE TABLE transacciones (
    id_transaccion BIGSERIAL,
    cuenta_origen BIGINT,
    cuenta_destino BIGINT,
    monto NUMERIC,
    moneda TEXT,
    fecha_transaccion TIMESTAMP,
    tipo_transaccion TEXT,
    PRIMARY KEY (id_transaccion, fecha_transaccion) 
);


SELECT create_distributed_table('transacciones', 'fecha_transaccion');

INSERT INTO transacciones (cuenta_origen, cuenta_destino, monto, moneda, fecha_transaccion, tipo_transaccion) 
VALUES (101, 202, 500.00, 'COP', '2024-01-15 10:00:00', 'Transferencia');

INSERT INTO transacciones (cuenta_origen, cuenta_destino, monto, moneda, fecha_transaccion, tipo_transaccion) 
VALUES (102, 203, 1500.00, 'COP', '2024-05-20 14:30:00', 'Pago');

INSERT INTO transacciones (cuenta_origen, cuenta_destino, monto, moneda, fecha_transaccion, tipo_transaccion) 
VALUES (103, 204, 200.00, 'COP', '2024-08-10 09:15:00', 'Retiro');

INSERT INTO transacciones (cuenta_origen, cuenta_destino, monto, moneda, fecha_transaccion, tipo_transaccion) 
VALUES (104, 205, 3000.00, 'COP', '2025-02-01 16:45:00', 'Deposito');

SET citus.explain_all_tasks = 1;
EXPLAIN ANALYZE SELECT * FROM transacciones;

