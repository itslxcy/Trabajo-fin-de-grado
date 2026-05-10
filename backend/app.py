import os
import string
import random
from datetime import datetime
from flask import Flask, render_template, request, redirect, url_for, jsonify
from modelos import SaacSistema, Idioma, SistemaRequisitoFuncional, TipoEntrada, Plataforma, HistorialRecomendacion, EntornoUso, MetodoComunicacion
from extension import bd
from dotenv import load_dotenv
from sqlalchemy import or_

load_dotenv()

app = Flask(__name__)

# --- CONFIGURACIÓN DE BASE DE DATOS ---
usuario = os.getenv('DB_USER')
contrasena = os.getenv('DB_PASSWORD')
host = os.getenv('DB_HOST')
puerto = os.getenv('DB_PORT')
base = os.getenv('DB_NAME')

app.config['SQLALCHEMY_DATABASE_URI'] = f'postgresql://{usuario}:{contrasena}@{host}:{puerto}/{base}'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
bd.init_app(app)

def generar_id_anonimo():
    caracteres = string.ascii_uppercase + string.digits
    return f"PAC-{''.join(random.choice(caracteres) for _ in range(6))}"

# --- RUTAS DE NAVEGACIÓN ---

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
def cuestionary():
    idiomas = Idioma.query.order_by(Idioma.id).all() 
    entradas = TipoEntrada.query.all()
    plataformas = Plataforma.query.all()
    return render_template('cuestionario.html', idiomas=idiomas, entradas=entradas, plataformas=plataformas)

# --- LÓGICA PRINCIPAL DE RECOMENDACIÓN ---

@app.route('/recomendar', methods=['POST'])
def recomendar():
    nombre_usuario = generar_id_anonimo()

    # 1. CAPTURA DE DATOS
    try:
        ids_idiomas = [int(x) for x in request.form.getlist('idioma_ids')]
        ids_entradas = [int(x) for x in request.form.getlist('entrada_ids')]
        ids_plataformas = [int(x) for x in request.form.getlist('plataforma_ids')]
        ids_metodos_usuario = [int(x) for x in request.form.getlist('alfabetizacion_ids')]
    except ValueError:
        ids_idiomas = ids_entradas = ids_plataformas = ids_metodos_usuario = []

    v_vision = int(request.form.get('vision', 0))
    v_audicion = int(request.form.get('audicion', 0))
    v_habla = int(request.form.get('habla', 0))
    v_resistencia = int(request.form.get('resistencia', 0))
    v_tecnologia = int(request.form.get('tecnologia', 0))
    v_autonomia_nivel = int(request.form.get('independencia', 0))
    v_entorno = request.form.get('entorno_principal', 'No definido')
    v_silla = request.form.get('usa_silla') == 'true'
    v_es_real = request.form.get('es_real') == 'true'

    # --- INICIALIZACIÓN DE LISTAS ---
    sistemas_finales = []
    sistemas_preventivos = [] 
    accesorios_referencia = []
    ids_acc_vistos = set() 
    bancos_voz_final = []

    # 2. LÓGICA DE FILTRADO BASE (SQL)
    consulta = SaacSistema.query.outerjoin(SistemaRequisitoFuncional)
    
    # Filtro de resistencia
    consulta = consulta.filter(or_(SaacSistema.fatiga_fisica <= v_resistencia, SaacSistema.fatiga_fisica == None))
    
    # Filtros clínicos (Nivel Usuario debe ser >= Nivel Mínimo del Sistema)
    # Nota: Si el usuario tiene 0 habla, no puede usar sistemas que requieran habla > 0
    campos_clinicos = [
        (SistemaRequisitoFuncional.nivel_visual_min, v_vision), 
        (SistemaRequisitoFuncional.nivel_tecnologico_min, v_tecnologia), 
        (SistemaRequisitoFuncional.nivel_auditivo_min, v_audicion),
        (SistemaRequisitoFuncional.nivel_habla_min, v_habla)
    ]
    for columna, valor in campos_clinicos:
        consulta = consulta.filter(or_(columna <= valor, columna == None))

    resultados_preliminares = consulta.all()

    # Cache de hardware
    todos_sist = SaacSistema.query.all()
    def buscar_hardware(keyword):
        return next((x for x in todos_sist if keyword.lower() in x.nombre.lower() and x.categoria == 'hardware'), None)

    pref = {
        'eye_tracker': buscar_hardware('Eye tracker'),
        'ipad': buscar_hardware('iPad'),
        'tablet': buscar_hardware('Tablet Android'),
        'laptop': buscar_hardware('Ordenador Portátil'),
    }

    ent_ojos = TipoEntrada.query.filter(TipoEntrada.nombre.ilike('%ojos%')).first()
    id_ojos = ent_ojos.id if ent_ojos else 999

    # 3. BUCLE DE FILTRADO DETALLADO (Python)
    for s in resultados_preliminares:
        # Filtro de Idiomas
        if ids_idiomas and not any(i.id in ids_idiomas for i in s.idiomas): continue
        
        # Filtro de Plataformas (Paneles físicos pasan siempre, apps filtran por plataforma)
        if ids_plataformas:
            s_plats_ids = [p.id for p in s.plataformas]
            plats_nombres = [p.nombre.lower() for p in s.plataformas]
            
            # Determinamos si es un sistema físico/papel:
            # - No tiene plataformas asignadas en la DB
            # - O su plataforma explícitamente se llama "Panel Físico", "Papel" o "Baja Tecnología"
            # - O el nombre del sistema indica que es un material físico
            es_sistema_fisico = (
                len(s_plats_ids) == 0 or 
                any(n in ["panel físico", "papel", "baja tecnología"] for n in plats_nombres) or
                any(keyword in s.nombre.lower() for keyword in ['panel', 'tablero', 'cuaderno', 'etran'])
            )

            # Si NO es físico y NO coincide con la plataforma del usuario (iOS/Android/Win), lo descartamos
            if not es_sistema_fisico:
                if not any(p_id in s_plats_ids for p_id in ids_plataformas):
                    continue

        # --- FILTRO DE MÉTODOS (Alfabeto/Pictogramas) ---
        if ids_metodos_usuario:
            metodos_sistema_ids = [m.id for m in s.metodos]
            # Si el sistema tiene métodos definidos, debe coincidir con alguno del usuario
            if metodos_sistema_ids and not any(m_id in ids_metodos_usuario for m_id in metodos_sistema_ids):
                continue

        # Filtro de Entradas
        if ids_entradas and s.entradas:
            if not any(e.id in ids_entradas for e in s.entradas): continue

        # --- EXCLUSIÓN LÓGICA DE HABLA ---
        # Si el usuario NO habla, eliminamos asistentes de reconocimiento de voz
        if v_habla == 0 and ("voz" in s.nombre.lower() and "asistente" in s.nombre.lower()):
            continue

        # --- ASIGNACIÓN DE ACCESORIOS Y LÓGICA PREVENTIVA ---
        s.nota_clinica = ""
        s.accesorio_vinculado = None
        s.dispositivo_base = None

        # Asignar dispositivo base según plataforma
        p_nombres_list = [p.nombre for p in s.plataformas]
        if 'iOS' in p_nombres_list: s.dispositivo_base = pref['ipad']
        elif 'Android' in p_nombres_list: s.dispositivo_base = pref['tablet']
        elif 'Windows' in p_nombres_list: s.dispositivo_base = pref['laptop']

        s_entradas_ids = [e.id for e in s.entradas]
        
        # Lógica para control ocular (ojos)
        if id_ojos in s_entradas_ids:
            if id_ojos not in ids_entradas: 
                # --- FILTRO PARA EVITAR HARDWARE Y PANELES EN PREVENTIVOS ---
                es_software = s.categoria == 'sistema' and not any(kw in s.nombre.lower() for kw in ['panel', 'tablero', 'cuaderno', 'etran'])
                
                # Solo si es software y requiere hardware extra (eye tracker)
                if es_software and s.requiere_hardware_extra:
                    s.accesorio_vinculado = pref['eye_tracker']
                    s.nota_clinica = "RECOMENDACIÓN PREVENTIVA: Entrenamiento temprano para el futuro control ocular."
                    sistemas_preventivos.append(s)
                    continue # Importante: No lo añade a la lista normal
                else:
                    # Si no es software "pesado" (ej. un panel o hardware), 
                    # simplemente no lo recomendamos de forma preventiva para no saturar.
                    continue 
            else:
                # Si el usuario SÍ marcó ojos, vinculamos el accesorio si lo requiere
                if s.requiere_hardware_extra: 
                    s.accesorio_vinculado = pref['eye_tracker']

        # Si llegamos aquí y no es hardware puro, se añade a la lista final
        if s.categoria == 'sistema':
            sistemas_finales.append(s)

    # 4. PREPARAR LISTAS PARA HTML
    recomendados = [s for s in sistemas_finales if s.categoria == 'sistema']
    
    for s in recomendados:
        for extra in [s.dispositivo_base, s.accesorio_vinculado]:
            if extra and extra.id not in ids_acc_vistos:
                accesorios_referencia.append(extra)
                ids_acc_vistos.add(extra.id)

    bancos_voz_final = [s for s in sistemas_finales if s.categoria == 'servicio']
    if not bancos_voz_final and v_habla >= 2:
        bancos_voz_final = SaacSistema.query.filter(SaacSistema.categoria == 'servicio').all()

    # 5. GUARDAR HISTORIAL
    h_id = None
    try:
        # Mapeo dinámico de nombres de métodos
        metodos_obj = MetodoComunicacion.query.filter(MetodoComunicacion.id.in_(ids_metodos_usuario)).all()
        metodos_nombres = [m.nombre for m in metodos_obj]
        idiomas_obj = Idioma.query.filter(Idioma.id.in_(ids_idiomas)).all()
        plataformas_obj = Plataforma.query.filter(Plataforma.id.in_(ids_plataformas)).all()
        metodos_obj = MetodoComunicacion.query.filter(MetodoComunicacion.id.in_(ids_metodos_usuario)).all()
        entradas_obj = TipoEntrada.query.filter(TipoEntrada.id.in_(ids_entradas)).all()
        nombres_entradas = [e.nombre for e in entradas_obj]

        datos_completos = {
            "vision": v_vision, 
            "audicion": v_audicion,
            "habla": v_habla,
            "resistencia": v_resistencia, 
            "tecnologia": v_tecnologia,
            "autonomia": f"Nivel {v_autonomia_nivel}", 
            "silla_ruedas": v_silla,
            "entorno": v_entorno,
            "interaccion": ", ".join(nombres_entradas) if nombres_entradas else "No definidas",
            "idioma": ", ".join([i.nombre for i in idiomas_obj]) if idiomas_obj else "No seleccionado",
            "plataforma_pref": ", ".join([p.nombre for p in plataformas_obj]) if plataformas_obj else "Cualquiera",
            "metodo_pref": ", ".join([m.nombre for m in metodos_obj]) if metodos_obj else "Sin preferencia"
        }


        texto_recomendacion = f"SISTEMAS: {', '.join([s.nombre for s in recomendados])}"
        if accesorios_referencia:
            texto_recomendacion += f" | ACCESORIOS: {', '.join([a.nombre for a in accesorios_referencia])}"

        nuevo_historial = HistorialRecomendacion(
            nombre_paciente=nombre_usuario,
            fecha=datetime.now(),
            input_usuario=datos_completos,
            sistemas_recomendados=texto_recomendacion,
            es_real=v_es_real
        )
        
        bd.session.add(nuevo_historial)
        bd.session.commit()
        h_id = nuevo_historial.id
    except Exception as e:
        bd.session.rollback()

    return render_template('recomendacion.html', 
                           nombre_usuario=nombre_usuario,
                           sistemas=recomendados, 
                           accesorios_referencia=accesorios_referencia,
                           sistemas_preventivos=sistemas_preventivos,
                           bancos_voz=bancos_voz_final,
                           mostrar_respaldo=True,
                           historial_id=h_id)

@app.route('/guardar-feedback', methods=['POST'])
def guardar_feedback():
    from sqlalchemy.orm.attributes import flag_modified
    h_id = request.form.get('historial_id')
    if h_id:
        fb = {k: request.form.get(k) for k in ['usa_actual', 'satisfaccion_actual', 'opcion_cambio', 'motivo_cambio', 'valoracion_general', 'comentarios_adicionales']}
        reg = bd.session.get(HistorialRecomendacion, h_id)
        if reg:
            reg.feedback = fb
            flag_modified(reg, "feedback")
            bd.session.commit()
    return render_template("gracias_feedback.html")

@app.route('/admin_historial')
def ver_historial():
    registros = HistorialRecomendacion.query.order_by(HistorialRecomendacion.id.desc()).all()
    return render_template('admin_historial.html', registros=registros)

if __name__ == '__main__':
    app.run(debug=True)
    
#Ejecución
#python backend/app.py
#http://127.0.0.1:5000
#http://127.0.0.1:5000/admin_historial