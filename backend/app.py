import os
from flask import Flask
from sqlalchemy import text
from flask_sqlalchemy import SQLAlchemy
from dotenv import load_dotenv

#Variables de entorno .env
load_dotenv() 

app = Flask(__name__)

#Config de la base de datos pgAdmin
usuario = os.getenv('DB_USER')
contrasena = os.getenv('DB_PASSWORD')
host = os.getenv('DB_HOST')
puerto = os.getenv('DB_PORT')
base = os.getenv('DB_NAME')

#URI protocolo + usuario y contraseña + ubicación + nombre base de datos
app.config['SQLALCHEMY_DATABASE_URI'] = f'postgresql://{usuario}:{contrasena}@{host}:{puerto}/{base}'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

bd = SQLAlchemy(app)

@app.route('/')
def inicio():
    return "primera prueba de la página web"

if __name__ == '__main__':
    app.run(debug=True)