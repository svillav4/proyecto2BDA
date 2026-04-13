import psycopg2
import pika
import json

def publicar_evento(tipo, data):
    # Conexión a RabbitMQ
    credentials = pika.PlainCredentials('guest', 'guest')
    connection = pika.BlockingConnection(
        pika.ConnectionParameters(host='localhost', credentials=credentials)
    )
    channel = connection.channel()
    channel.queue_declare(queue='eventos_pedidos') # Crea la cola si no existe

    mensaje = {'tipo': tipo, 'data': data}
    channel.basic_publish(exchange='', routing_key='eventos_pedidos', body=json.dumps(mensaje))
    print(f" [x] Evento enviado a RabbitMQ: {mensaje}")
    connection.close()

def crear_pedido(usuario_id, productos, total):
    conn = psycopg2.connect(host="localhost", port=5450, database="command_db", user="admin", password="admin123")
    cursor = conn.cursor()
    cursor.execute("INSERT INTO pedidos (usuario_id, productos, total, estado, fecha) VALUES (%s, %s, %s, 'pendiente', NOW()) RETURNING id_pedido", (usuario_id, productos, total))
    pedido_id = cursor.fetchone()[0]
    conn.commit()
    
    # El puente de CQRS:
    publicar_evento('pedido_creado', {'producto_id': 1, 'cantidad': 1}) # Simplificado para el ejemplo
    return pedido_id

if __name__ == "__main__":
    print("Iniciando proceso de checkout...")
    try:
        id_generado = crear_pedido(1, "Pack Café Especial", 45000)
        print(f"Éxito total. Pedido #{id_generado} creado y evento enviado.")
    except Exception as e:
        print(f"Error en el proceso: {e}")