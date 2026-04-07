import os
from flask import Flask , render_template
from dotenv import load_dotenv
from extension import bd  # Importamos bd
import modelos            # Importamos los modelos para que Flask los reconozca
from modelos import SaacSistema 


load_dotenv()

app = Flask(__name__)

# Configuración
usuario = os.getenv('DB_USER')
contrasena = os.getenv('DB_PASSWORD')
host = os.getenv('DB_HOST')
puerto = os.getenv('DB_PORT')
base = os.getenv('DB_NAME')

app.config['SQLALCHEMY_DATABASE_URI'] = f'postgresql://{usuario}:{contrasena}@{host}:{puerto}/{base}'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Unimos el objeto bd con nuestra aplicación Flask específica
bd.init_app(app)

@app.route('/sistemas')
def mostrar_sistemas():
    # Consultamos todos los sistemas de la tabla saac_sistema
    todos_los_sistemas = SaacSistema.query.all()
    
    # Enviamos los datos al archivo HTML
    return render_template('sistemas.html', lista=todos_los_sistemas)

if __name__ == '__main__':
    app.run(debug=True)



#python backend/app.py
#http://127.0.0.1:5000