-- Estructura para simulación de base de datos bancaria distribuida
CREATE TABLE IF NOT EXISTS cuentas (
    id_cuenta SERIAL PRIMARY KEY,
    titular VARCHAR(100) NOT NULL,
    saldo NUMERIC(15, 2) DEFAULT 0.00,
    tipo_cuenta VARCHAR(20),
    fecha_apertura TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS movimientos (
    id_movimiento SERIAL PRIMARY KEY,
    id_cuenta INT REFERENCES cuentas(id_cuenta),
    tipo_movimiento VARCHAR(20), -- 'DEPOSITO', 'RETIRO', 'TRANSFERENCIA'
    monto NUMERIC(15, 2),
    fecha_movimiento TIMESTAMP DEFAULT NOW()
);

-- Datos de prueba para verificar la replicación/distribución
INSERT INTO cuentas (titular, saldo, tipo_cuenta) VALUES 
('Darieth Engineering', 5000000.00, 'Ahorros'),
('Sasha Pet Store', 1200000.00, 'Corriente')
ON CONFLICT DO NOTHING;