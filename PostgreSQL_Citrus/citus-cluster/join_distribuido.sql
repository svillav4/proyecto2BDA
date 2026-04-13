DROP TABLE IF EXISTS transacciones;
DROP TABLE IF EXISTS usuarios;


CREATE TABLE usuarios (
    id_usuario SERIAL PRIMARY KEY,
    nombre TEXT,
    email TEXT
);

CREATE TABLE transacciones (
    id_transaccion BIGSERIAL,
    cuenta_origen BIGINT, 
    monto NUMERIC,
    fecha_transaccion TIMESTAMP,
    PRIMARY KEY (id_transaccion, cuenta_origen)
);


SELECT create_distributed_table('usuarios', 'id_usuario');

-- Ahora distribuimos la segunda indicando que DEBE vivir con la primera
SELECT create_distributed_table('transacciones', 'cuenta_origen', colocate_with => 'usuarios');

-- 4. Datos de prueba
INSERT INTO usuarios (nombre) VALUES ('Darieth');
INSERT INTO transacciones (cuenta_origen, monto, fecha_transaccion) VALUES (1, 1250.00, NOW());


EXPLAIN ANALYZE 
SELECT u.nombre, t.monto 
FROM usuarios u 
JOIN transacciones t ON u.id_usuario = t.cuenta_origen;