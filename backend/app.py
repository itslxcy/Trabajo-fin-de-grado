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

    # --- LÓGICA DE PROCESAMIENTO ---
    sistemas_finales = []
    accesorios_referencia = []
    ids_accesorios_vistos = set() 
    
    for s in resultados:
        s.nota_clinica = ""
        s.accesorio_vinculado = None 
        s.prioridad_entorno = 0 # 0: Óptimo, 1: Con advertencias
        nombre_low = s.nombre.lower()
        
        # A. Notas Clínicas Preventivas
        if any(kw in nombre_low for kw in ['modeltalker', 'myownvoice', 'vocalid', 'bank your voice']):
            s.nota_clinica = "URGENTE: Ventana de oportunidad óptima. Iniciar preservación de voz antes de síntomas bulbares."
        
        if 'praat' in nombre_low or 'voice analyst' in nombre_low:
            s.nota_clinica = "Prioritario: Evaluación fonoaudiológica recomendada para detectar cambios acústicos imperceptibles."

        # B. Vinculación de Periféricos Inteligente
        if not s.es_accesorio:
            # B.1. Vinculación de Eye Tracker
            if s.nombre in ['Grid 3', 'Verbo', 'TD Snap', 'Tallk', 'Look to learn']:
                s.accesorio_vinculado = next((x for x in resultados if x.nombre == 'Eye tracker'), None)
            
            # B.2. Vinculación de Punteros (Cefálica vs Manual)
            if s.nombre in ['Panel alfabético', 'Panel pictogramas', 'SpeakBook']:
                if 3 in ids_entradas or v_resistencia <= 1:
                    s.accesorio_vinculado = next((x for x in resultados if 'Gafas' in x.nombre), None)
                if not s.accesorio_vinculado:
                    s.accesorio_vinculado = next((x for x in resultados if x.nombre == 'Puntero Láser'), None)

            # C. Notas de Contexto, Soporte y Priorización
            if v_silla and s.admite_anclaje:
                s.nota_clinica += " | Requiere soporte de fijación a silla."
                
                # Buscamos el soporte en los resultados para incluirlo en la tabla de referencia final
                soporte = next((x for x in resultados if 'Soporte' in x.nombre), None)
                if soporte and soporte.id not in ids_accesorios_vistos:
                    accesorios_referencia.append(soporte)
                    ids_accesorios_vistos.add(soporte.id)
            
            if v_entorno == 'exterior':
                # 1. Identificamos si es un sistema de mirada (con problemas IR)
                es_sistema_mirada = s.accesorio_vinculado and s.accesorio_vinculado.nombre == 'Eye tracker'
                
                if es_sistema_mirada:
                    s.nota_clinica += " | ADVERTENCIA: El seguimiento ocular puede perder precisión bajo luz solar directa."
                    s.prioridad_entorno = 1 # Bajamos prioridad por limitación técnica
                
                # 2. Solo marcamos como optimizado si es realmente portable y NO tiene fallos de precisión por luz
                if s.portable and not es_sistema_mirada:
                    s.nota_clinica += " | Optimizado para movilidad exterior."
                
                # 3. Si el sistema no es portable en absoluto, bajamos su prioridad en la lista
                if not s.portable:
                    s.prioridad_entorno = 1

            sistemas_finales.append(s)

    # Ordenar: primero los de prioridad 0 (sin problemas de entorno)
    sistemas_finales.sort(key=lambda x: x.prioridad_entorno)

    # D. Recopilación de hardware único para la tabla de referencia
    for s in sistemas_finales:
        acc = s.accesorio_vinculado
        if acc and acc.id not in ids_accesorios_vistos:
            nombre_acc_low = acc.nombre.lower()
            es_software_o_banco = any(kw in nombre_acc_low for kw in 
                                    ['modeltalker', 'myownvoice', 'vocalid', 'bank your voice', 'praat', 'analyst'])
            
            if not es_software_o_banco:
                accesorios_referencia.append(acc)
                ids_accesorios_vistos.add(acc.id)

    return render_template('recomendacion.html', 
                           sistemas=sistemas_finales, 
                           accesorios_referencia=accesorios_referencia,
                           nombre_usuario=nombre)

if __name__ == '__main__':
    app.run(debug=True)

#python backend/app.py
#http://127.0.0.1:5000