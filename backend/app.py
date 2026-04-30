import os
import modelos
from flask import Flask, render_template, request
from modelos import SaacSistema, Idioma, SistemaRequisitoFuncional, TipoEntrada, Plataforma
from extension import bd
from dotenv import load_dotenv
from sqlalchemy import or_

load_dotenv()

app = Flask(__name__)

# Configuración de la Base de Datos
usuario = os.getenv('DB_USER')
contrasena = os.getenv('DB_PASSWORD')
host = os.getenv('DB_HOST')
puerto = os.getenv('DB_PORT')
base = os.getenv('DB_NAME')

app.config['SQLALCHEMY_DATABASE_URI'] = f'postgresql://{usuario}:{contrasena}@{host}:{puerto}/{base}'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

bd.init_app(app)

@app.route('/')
def informar():
    return render_template("informacion.html")

@app.route('/ELA')
def info_ela():
    return render_template("ELA.html")

@app.route('/SAAC')
def info_saac():
    return render_template("SAAC.html")

@app.route('/cuestionario')
def cuestionario():
    idiomas = Idioma.query.order_by(Idioma.id).all() 
    entradas = TipoEntrada.query.all()
    plataformas = Plataforma.query.all()
    
    return render_template('cuestionario.html', 
                           idiomas=idiomas, 
                           entradas=entradas, 
                           plataformas=plataformas)

@app.route('/recomendar', methods=['POST'])
def recomendar():
    # 1. Capturar datos básicos
    nombre = request.form.get('nombre')
    ids_idiomas = [int(x) for x in request.form.getlist('idioma_ids') if x]
    ids_entradas = [int(x) for x in request.form.getlist('entrada_ids') if x]
    ids_plataformas = [int(x) for x in request.form.getlist('plataforma_ids') if x]
    
    # 2. Capturar Entorno y Otros
    v_entorno = request.form.get('entorno_principal') 
    v_silla = request.form.get('usa_silla') == 'true'
    
    try:
        v_presupuesto = float(request.form.get('presupuesto', 999999))
    except:
        v_presupuesto = 999999.0

    # 3. Capturar Capacidades (Niveles 0-3)
    v_vision = int(request.form.get('vision', 3))
    v_audicion = int(request.form.get('audicion', 3))
    v_habla = int(request.form.get('habla', 3))
    v_cognicion = int(request.form.get('cognicion', 3))
    v_tecno = int(request.form.get('tecnologia', 3))
    v_resistencia = int(request.form.get('resistencia', 3))
    v_independencia = int(request.form.get('independencia', 3))

    # --- CONSULTA BASE ---
    consulta = SaacSistema.query.outerjoin(SistemaRequisitoFuncional)

    # FILTROS ESTÁNDAR
    consulta = consulta.filter(SaacSistema.coste_min <= v_presupuesto)

    if ids_idiomas:
        consulta = consulta.filter(SaacSistema.idiomas.any(Idioma.id.in_(ids_idiomas)))

    consulta = consulta.filter(
        or_(SistemaRequisitoFuncional.nivel_visual_min <= v_vision, SistemaRequisitoFuncional.nivel_visual_min == None),
        or_(SistemaRequisitoFuncional.nivel_cognitivo_min <= v_cognicion, SistemaRequisitoFuncional.nivel_cognitivo_min == None),
        or_(SistemaRequisitoFuncional.nivel_tecnologico_min <= v_tecno, SistemaRequisitoFuncional.nivel_tecnologico_min == None),
        or_(SistemaRequisitoFuncional.nivel_auditivo_min <= v_audicion, SistemaRequisitoFuncional.nivel_auditivo_min == None),
        or_(SistemaRequisitoFuncional.nivel_habla_min <= v_habla, SistemaRequisitoFuncional.nivel_habla_min == None)
    )

    if v_independencia == 0:
        consulta = consulta.filter(SaacSistema.requiere_interlocutor == True)

    if ids_entradas:
        consulta = consulta.filter(SaacSistema.entradas.any(TipoEntrada.id.in_(ids_entradas)))
    if ids_plataformas:
        consulta = consulta.filter(SaacSistema.plataformas.any(Plataforma.id.in_(ids_plataformas)))

    resultados = consulta.all()

    # --- LÓGICA DE POST-PROCESAMIENTO (Protocolo 2026) ---
    sistemas_finales = []
    accesorios_finales = []

    for s in resultados:
        s.nota_clinica = ""
        nombre_low = s.nombre.lower()
        
        # A. Implementación Voice Banking (Habla Nivel 3)
        is_voice_banking = any(kw in nombre_low for kw in ['modeltalker', 'myownvoice', 'vocalid', 'bank your voice'])
        if is_voice_banking:
            if v_habla == 3:
                s.nota_clinica = "URGENTE: Ventana de oportunidad óptima. Iniciar preservación de voz antes de síntomas bulbares para mantener identidad vocal."
            else:
                s.nota_clinica = "Recomendado: Preservación de voz para uso en dispositivos SGD/AAC."

        # B. Análisis Acústico Preventivo (Audición Nivel 1 o Habla Nivel 3)[cite: 1]
        if 'praat' in nombre_low or 'voice analyst' in nombre_low:
            if v_audicion == 1 or v_habla == 3:
                s.nota_clinica = "Prioritario: Evaluación fonoaudiológica recomendada para detectar cambios acústicos imperceptibles al oído.[cite: 1]"

        # C. Notas de Contexto (Silla/Entorno)
        if v_silla and s.admite_anclaje:
            s.nota_clinica += " | Requiere soporte de fijación a silla."
        
        if v_entorno == 'exterior' and s.portable:
            s.nota_clinica += " | Optimizado para movilidad exterior."

        # Clasificación Final
        if s.es_accesorio:
            accesorios_finales.append(s)
        else:
            sistemas_finales.append(s)

    return render_template('recomendacion.html', 
                           sistemas=sistemas_finales, 
                           accesorios=accesorios_finales,
                           nombre_usuario=nombre,
                           v_habla=v_habla,
                           v_audicion=v_audicion)

if __name__ == '__main__':
    app.run(debug=True)
    
#python backend/app.py
#http://127.0.0.1:5000