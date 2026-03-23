import os
from flask import Flask
from sqlalchemy import text
from flask_sqlalchemy import SQLAlchemy
from dotenv import load_dotenv

load_dotenv() 

app = Flask(__name__)

user = os.getenv('DB_USER')
password = os.getenv('DB_PASSWORD')
host = os.getenv('DB_HOST')
port = os.getenv('DB_PORT')
name = os.getenv('DB_NAME')

print(f"DEBUG: Intentando conectar a {name} en el puerto {port}")

app.config['SQLALCHEMY_DATABASE_URI'] = f'postgresql://{user}:{password}@{host}:{port}/{name}'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

@app.route('/')
def inicio():
    try:
        #Respuesta de la base de datos
        db.session.execute(text('SELECT 1'))
        return "<h1>¡Conexión lista!</h1><p>Tu TFG ya está conectado a pgAdmin.</p>"
    except Exception as e:
        return f"<h1>Error de conexión</h1><p>{str(e)}</p>"

if __name__ == '__main__':
    app.run(debug=True)