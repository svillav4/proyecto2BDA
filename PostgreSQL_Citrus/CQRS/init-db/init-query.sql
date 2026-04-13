
CREATE TABLE IF NOT EXISTS productos (
    id_producto INT PRIMARY KEY,
    nombre VARCHAR(100),
    precio NUMERIC(10, 2),
    categoria VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS ventas (
    producto_id INT REFERENCES productos(id_producto),
    cantidad INT DEFAULT 0
);

-- Datos iniciales para pruebas
INSERT INTO productos (id_producto, nombre, precio, categoria) VALUES 
(1, 'Pack Café Especial', 45000, 'Cafetería'),
(2, 'Prensa Francesa', 85000, 'Accesorios')
ON CONFLICT (id_producto) DO NOTHING;

INSERT INTO ventas (producto_id, cantidad) VALUES (1, 0), (2, 0);