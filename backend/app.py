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
    # 1. Captura de datos
    id_idioma = request.form.get('idioma_id')
    
    # Capacidades (Añadimos v_habla)
    v_vision = int(request.form.get('vision', 3))
    v_audicion = int(request.form.get('audicion', 3))
    v_cognicion = int(request.form.get('cognicion', 3))
    v_habla = int(request.form.get('habla', 3))  # <-- Nueva
    v_tecno = int(request.form.get('tecnologia', 3))
    v_resistencia = int(request.form.get('resistencia', 3))
    
    # Ayudas y Entorno
    v_ayuda_inicial = request.form.get('ayuda_inicial') == 'true'
    v_ayuda_diaria = request.form.get('ayuda_diaria') == 'true'
    v_usa_silla = request.form.get('usa_silla') == 'true'
    
    raw_presupuesto = request.form.get('presupuesto')
    v_presupuesto = float(raw_presupuesto) if raw_presupuesto else 999999.0

    # --- LÓGICA DE FILTRADO ---
    consulta = SaacSistema.query.join(SistemaRequisitoFuncional)

    # A. Filtro de Idioma
    if id_idioma:
        consulta = consulta.filter(SaacSistema.idiomas.any(id=id_idioma))

    # B. Filtros de Capacidades (Incluyendo Habla)
    # Requisito del sistema <= Capacidad del paciente
    consulta = consulta.filter(
        SistemaRequisitoFuncional.nivel_visual_min <= v_vision,
        SistemaRequisitoFuncional.nivel_auditivo_min <= v_audicion,
        SistemaRequisitoFuncional.nivel_cognitivo_min <= v_cognicion,
        SistemaRequisitoFuncional.nivel_habla_min <= v_habla, # <-- Filtro de habla
        SistemaRequisitoFuncional.nivel_tecnologico_min <= v_tecno
    )

    # C. Lógica de Seguridad (Ayuda inicial/Tecnología)
    if (v_tecno <= 1 or v_cognicion <= 1) and not v_ayuda_inicial:
        consulta = consulta.filter(SistemaRequisitoFuncional.nivel_tecnologico_min <= 1)
        consulta = consulta.filter(SaacSistema.requiere_interlocutor == False)

    # D. Lógica de Seguridad (Ayuda diaria/Fatiga)
    if v_resistencia == 0 and not v_ayuda_diaria:
        consulta = consulta.filter(SaacSistema.fatiga_fisica <= 1)

    # E. Filtros Generales (Fatiga, Presupuesto, Silla)
    consulta = consulta.filter(SaacSistema.fatiga_fisica <= v_resistencia)
    consulta = consulta.filter(SaacSistema.coste_min <= v_presupuesto)
    if v_usa_silla:
        consulta = consulta.filter(SaacSistema.admite_anclaje == True)

    resultados = consulta.all()
    return render_template('sistemas.html', lista=resultados)

if __name__ == '__main__':
    app.run(debug=True)



#python backend/app.py
#http://127.0.0.1:5000/cuestionario