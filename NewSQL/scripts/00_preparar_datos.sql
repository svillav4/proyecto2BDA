-- 00_preparar_datos.sql
-- Insertar datos de prueba para las demostraciones

-- Insertar países
INSERT INTO countries (name, iso_code) VALUES 
    ('Colombia', 'COL'),
    ('México', 'MEX'),
    ('Argentina', 'ARG')
ON CONFLICT DO NOTHING;

-- Insertar clientes de prueba
INSERT INTO customers (customer_id, full_name, country_id) VALUES 
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Cliente A', 1),
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Cliente B', 1),
    ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Cliente C', 2)
ON CONFLICT DO NOTHING;

-- Insertar cuentas de prueba (con balances conocidos)
INSERT INTO accounts (account_id, customer_id, country_id, account_type, currency, balance) VALUES 
    ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 1, 'checking', 'USD', 1000),
    ('22222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 1, 'checking', 'USD', 2000),
    ('33333333-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 2, 'savings', 'USD', 3000)
ON CONFLICT DO NOTHING;

-- Verificar datos
SELECT 'Datos preparados correctamente' as status;
SELECT COUNT(*) as total_accounts FROM accounts;
SELECT account_id, balance FROM accounts;