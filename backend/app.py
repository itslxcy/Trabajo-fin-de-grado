import os
from flask import Flask , render_template, request
from dotenv import load_dotenv
from extension import bd  # Importamos bd
import modelos            # Importamos los modelos para que Flask los reconozca
from modelos import SaacSistema , Idioma, SistemaRequisitoFuncional


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

@app.route('/cuestionario')
def cuestionario():
    #Cargamos los idiomas para que el desplegable sea real
    lista_idiomas = Idioma.query.all()
    return render_template('cuestionario.html', idiomas=lista_idiomas)

@app.route('/recomendar', methods=['POST'])
def recomendar():
    #Recoger los datos del formulario
    idioma_id = request.form.get('idioma_id')
    nivel_vision = int(request.form.get('vision'))

    #Filtrar la base de datos (Lógica de recomendación)
    #Buscamos sistemas que soporten el idioma Y cumplan el requisito visual
    resultados = SaacSistema.query.join(SistemaRequisitoFuncional).filter(
        SaacSistema.idiomas.any(id=idioma_id),
        SistemaRequisitoFuncional.nivel_visual_min <= nivel_vision
    ).all()

    return render_template('sistemas.html', lista=resultados)

if __name__ == '__main__':
    app.run(debug=True)



#python backend/app.py
#http://127.0.0.1:5000