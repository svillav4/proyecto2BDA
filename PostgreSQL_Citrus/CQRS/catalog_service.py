import psycopg2

def consultar_productos_destacados():
    # Conectar a base de QUERY (lectura) - optimizada para consultas
    conn = psycopg2.connect(host="localhost", port=5451, database="query_db", user="admin", password="admin123")
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT p.nombre, p.precio, p.categoria, 
               COALESCE(SUM(v.cantidad), 0) as ventas_totales
        FROM productos p
        LEFT JOIN ventas v ON p.id_producto = v.producto_id
        GROUP BY p.id_producto
        ORDER BY ventas_totales DESC
        LIMIT 10
    """)
    
    return cursor.fetchall()

if __name__ == "__main__":
    destacados = consultar_productos_destacados()
    print("--- Productos Destacados (Desde DB de Lectura) ---")
    for prod in destacados:
        print(f"Producto: {prod[0]} | Ventas: {prod[3]}")