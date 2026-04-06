CREATE TABLE paises (
id_pais SERIAL PRIMARY KEY,
nombre TEXT,
codigo_iso TEXT
);

CREATE TABLE clientes (
id_cliente BIGSERIAL PRIMARY KEY,
nombre TEXT,
pais_residencia INT REFERENCES paises(id_pais),
fecha_registro TIMESTAMP
);

CREATE TABLE cuentas (
id_cuenta BIGSERIAL PRIMARY KEY,
id_cliente BIGINT REFERENCES clientes(id_cliente),
id_pais INT REFERENCES paises(id_pais),
moneda TEXT,
saldo NUMERIC,
fecha_creacion TIMESTAMP
);

CREATE TABLE transacciones (
id_transaccion BIGSERIAL PRIMARY KEY,
cuenta_origen BIGINT,
cuenta_destino BIGINT,
monto NUMERIC,
moneda TEXT,
fecha_transaccion TIMESTAMP,
tipo_transaccion TEXT
);