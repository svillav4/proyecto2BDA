import pika
import psycopg2
import json

def callback(ch, method, properties, body):
    evento = json.loads(body)
    data = evento['data']
    
    # Conectar a la base de QUERY (Lectura)
    conn = psycopg2.connect(host="localhost", port=5451, database="query_db", user="admin", password="admin123")
    cursor = conn.cursor()
    
    # Actualizar la tabla de ventas (Modelo de lectura)
    cursor.execute("UPDATE ventas SET cantidad = cantidad + %s WHERE producto_id = %s", (data['cantidad'], data['producto_id']))
    conn.commit()
    print(f" [v] Base de datos de CONSULTA actualizada: +{data['cantidad']} ventas.")
    conn.close()

credentials = pika.PlainCredentials('guest', 'guest')
connection = pika.BlockingConnection(
    pika.ConnectionParameters(host='localhost', credentials=credentials)
)
channel = connection.channel()
channel.queue_declare(queue='eventos_pedidos')
channel.basic_consume(queue='eventos_pedidos', on_message_callback=callback, auto_ack=True)

print(' [*] Esperando eventos para sincronizar... Presiona CTRL+C')
channel.start_consuming()