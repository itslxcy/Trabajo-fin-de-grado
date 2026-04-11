import os
from flask import Flask , render_template, request
from dotenv import load_dotenv
from extension import bd  # Importamos bd
import modelos            # Importamos los modelos para que Flask los reconozca
from modelos import SaacSistema , Idioma, SistemaRequisitoFuncional, TipoEntrada, Plataforma


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
    # Cargamos todas las opciones de la base de datos para los desplegables
    idiomas = Idioma.query.all()
    entradas = TipoEntrada.query.all()
    plataformas = Plataforma.query.all()
    
    return render_template('cuestionario.html', 
                           idiomas=idiomas, 
                           entradas=entradas, 
                           plataformas=plataformas)

@app.route('/recomendar', methods=['POST'])
def recomendar():
    # 1. Recoger datos del formulario
    id_idioma = request.form.get('idioma_id')
    id_entrada = request.form.get('entrada_id')
    id_plataforma = request.form.get('plataforma_id')
    v_vision = int(request.form.get('vision'))
    v_cognicion = int(request.form.get('cognicion'))

    # 2. Lógica de Filtrado (El corazón del sistema experto)
    consulta = SaacSistema.query.join(SistemaRequisitoFuncional).filter(
        SaacSistema.idiomas.any(id=id_idioma),
        SaacSistema.entradas.any(id=id_entrada),
        SaacSistema.plataformas.any(id=id_plataforma),
        SistemaRequisitoFuncional.nivel_visual_min <= v_vision,
        SistemaRequisitoFuncional.nivel_cognitivo_min <= v_cognicion
    )
    resultados = consulta.all()

    # 3. Mostrar resultados
    return render_template('sistemas.html', lista=resultados)

if __name__ == '__main__':
    app.run(debug=True)



#python backend/app.py
#http://127.0.0.1:5000/cuestionario