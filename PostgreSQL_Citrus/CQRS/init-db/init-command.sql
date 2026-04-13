CREATE TABLE IF NOT EXISTS pedidos (
    id_pedido SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL,
    productos TEXT NOT NULL,
    total NUMERIC(10, 2) NOT NULL,
    estado VARCHAR(20) DEFAULT 'pendiente',
    fecha TIMESTAMP DEFAULT NOW()
);