import os
import string
import random
from datetime import datetime
from flask import Flask, render_template, request, redirect, url_for
from modelos import SaacSistema, Idioma, SistemaRequisitoFuncional, TipoEntrada, Plataforma, HistorialRecomendacion
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
    ids_idiomas = [int(x) for x in request.form.getlist('idioma_ids') if x]
    ids_entradas = [int(x) for x in request.form.getlist('entrada_ids') if x]
    ids_plataformas = [int(x) for x in request.form.getlist('plataforma_ids') if x]
    ids_metodos_usuario = [int(x) for x in request.form.getlist('alfabetizacion_ids') if x]
    
    v_silla = request.form.get('usa_silla') == 'true'
    v_vision = int(request.form.get('vision', 3))
    v_habla = int(request.form.get('habla', 3))
    v_resistencia = int(request.form.get('resistencia', 3))
    v_independencia = int(request.form.get('independencia', 3))
    v_tecnologia = int(request.form.get('tecnologia', 3))
    v_audicion = int(request.form.get('audicion', 3))
    
    ids_alfabetizacion = [int(x) for x in request.form.getlist('alfabetizacion_ids') if x]
    v_alfabetizacion = max(ids_alfabetizacion) if ids_alfabetizacion else 3

    # Identificación dinámica de IDs críticos
    ent_ojos = TipoEntrada.query.filter(TipoEntrada.nombre.ilike('%ojos%')).first()
    id_ojos = ent_ojos.id if ent_ojos else 999
    ent_puls = TipoEntrada.query.filter(TipoEntrada.nombre.ilike('%pulsador%')).first()
    id_pulsador = ent_puls.id if ent_puls else 888

    # Voice Banking (Solo si conserva habla funcional)
    bancos_voz_informativa = []
    if v_habla >= 2:
        bancos_voz_informativa = SaacSistema.query.filter(or_(
            SaacSistema.nombre.ilike('%voice%'), SaacSistema.nombre.ilike('%banking%'),
            SaacSistema.nombre.ilike('%vocalid%'), SaacSistema.nombre.ilike('%model%'),
            SaacSistema.nombre.ilike('%myownvoice%')
        )).all()

    # Consulta Base con Filtros Clínicos
    consulta = SaacSistema.query.outerjoin(SistemaRequisitoFuncional)
    consulta = consulta.filter(or_(SaacSistema.fatiga_fisica <= v_resistencia, SaacSistema.fatiga_fisica == None))

    campos_clinicos = [
        (SistemaRequisitoFuncional.nivel_visual_min, v_vision), 
        (SistemaRequisitoFuncional.nivel_tecnologico_min, v_tecnologia), 
        (SistemaRequisitoFuncional.nivel_auditivo_min, v_audicion)
    ]
    for columna, valor in campos_clinicos:
        consulta = consulta.filter(or_(columna <= valor, columna == None))

    resultados_preliminares = consulta.all()

    sistemas_finales = []
    sistemas_preventivos = [] 
    accesorios_referencia = []
    ids_acc_vistos = set() 
    
    todos_sist = SaacSistema.query.all()
    def buscar_pref(keyword):
        return next((x for x in todos_sist if keyword.lower() in x.nombre.lower()), None)

    pref = {
        'eye_tracker': buscar_pref('Eye tracker'),
        'soporte': buscar_pref('Soporte'),
        'ipad': buscar_pref('iPad'),
        'tablet': buscar_pref('Tablet Android'),
        'laptop': buscar_pref('Ordenador Portátil'),
        'conmutador': buscar_pref('Conmutador') or buscar_pref('Pedal')
    }

    # Elementos excluidos de la tabla principal de SAAC para ir a Referencias
    nombres_hardware_excluidos = [
        'tracker', 'puntero', 'soporte', 'conmutador', 'pedal', 'guante', 
        'lápiz', 'ratón', 'bjoy', 'chin', 'enchufe', 'hub', 'alexa', 'google home'
    ]

    for s in resultados_preliminares:
        nombre_lower = s.nombre.lower()
        if any(kw in nombre_lower for kw in nombres_hardware_excluidos) or any(kw in nombre_lower for kw in ['voice', 'banking']):
            continue

        # Filtro Idioma
        if ids_idiomas:
            s_idiomas = [i.id for i in s.idiomas]
            if not any(idioma_id in s_idiomas for idioma_id in ids_idiomas): continue

        # Filtro Plataforma
        if ids_plataformas:
            s_plats = [p.id for p in s.plataformas]
            es_fisico = any("panel físico" in p.nombre.lower() or "papel" in p.nombre.lower() for p in s.plataformas)
            if not es_fisico and not any(p_id in s_plats for p_id in ids_plataformas): continue

        if ids_metodos_usuario:
            # Obtenemos los IDs de los métodos que soporta este sistema específico
            s_metodos_ids = [m.id for m in s.metodos]
            
            # Si el sistema no ofrece NINGUNO de los métodos que el usuario marcó, saltamos
            if not any(m_id in s_metodos_ids for m_id in ids_metodos_usuario):
                continue

        # Filtro Entrada
        if ids_entradas:
            s_entradas = [e.id for e in s.entradas]
            if not any(e_id in s_entradas for e_id in ids_entradas): continue

        s.nota_clinica = ""
        s.accesorio_vinculado = None 
        s.dispositivo_base = None 
        
        plats_nombres = [p.nombre for p in s.plataformas]
        if 'iOS' in plats_nombres: s.dispositivo_base = pref['ipad']
        elif 'Android' in plats_nombres: s.dispositivo_base = pref['tablet']
        elif 'Windows' in plats_nombres: s.dispositivo_base = pref['laptop']

        ids_s_entradas = [e.id for e in s.entradas]
        s.peso_esfuerzo = 1 if 1 in ids_s_entradas else 5 if id_ojos in ids_s_entradas else 3

        # --- VINCULACIÓN INTELIGENTE ---
        
        # 1. Mirada
        if id_ojos in ids_s_entradas:
            if id_ojos not in ids_entradas: # Preventivo
                if not s.requiere_interlocutor: s.accesorio_vinculado = pref['eye_tracker']
                s.nota_clinica = "RECOMENDACIÓN PREVENTIVA: Entrenamiento precoz con mirada."
                sistemas_preventivos.append(s)
                continue
            else: # Actual
                if not s.requiere_interlocutor: s.accesorio_vinculado = pref['eye_tracker']

        # 2. Pulsador
        if id_pulsador in ids_s_entradas and id_pulsador in ids_entradas:
            es_software = not s.requiere_interlocutor and s.fatiga_fisica is not None
            if es_software or 'quick' in nombre_lower:
                s.accesorio_vinculado = pref['conmutador']
                s.nota_clinica += " | Configurar modo Barrido (Scanning)."

        if s.requiere_interlocutor:
            s.nota_clinica += " Sistema de baja tecnología: requiere interlocutor."

        if v_silla and s.admite_anclaje:
            s.nota_clinica += " | Requiere soporte de fijación a silla."

        if s.accesorio_vinculado and 'tracker' in s.accesorio_vinculado.nombre.lower():
            s.nota_clinica += " | ENTORNO: Evite luz solar directa."

        sistemas_finales.append(s)

    sistemas_finales.sort(key=lambda x: x.peso_esfuerzo)

    # --- RECOPILACIÓN DE ACCESORIOS DE REFERENCIA ---

    # Añadir hardware vinculado a los sistemas elegidos
    for s in sistemas_finales:
        for extra in [s.dispositivo_base, s.accesorio_vinculado]:
            if extra and extra.id not in ids_acc_vistos:
                accesorios_referencia.append(extra)
                ids_acc_vistos.add(extra.id)

    # Añadir hardware por tipo de entrada (Ej: Barbilla/Soplido)
    if any(e_id in [3, 5] for e_id in ids_entradas): # IDs de Cabeza o Pulsador
        accesorios_input = SaacSistema.query.filter(or_(
            SaacSistema.nombre.ilike('%bjoy%'), 
            SaacSistema.nombre.ilike('%chin%'),
            SaacSistema.nombre.ilike('%pufo%')
        )).all()
        for acc in accesorios_input:
            if acc.id not in ids_acc_vistos:
                accesorios_referencia.append(acc)
                ids_acc_vistos.add(acc.id)

    # Lógica de Domótica corregida (Filtro de Habla)
    if v_tecnologia >= 2:
        # Los asistentes de voz (Alexa/Google) SOLO si el usuario puede hablar
        if v_habla >= 2:
            asistentes = SaacSistema.query.filter(or_(
                SaacSistema.nombre.ilike('%alexa%'),
                SaacSistema.nombre.ilike('%google home%')
            )).all()
            for a in asistentes:
                if a.id not in ids_acc_vistos:
                    accesorios_referencia.append(a)
                    ids_acc_vistos.add(a.id)
        
        # El Enchufe se recomienda siempre que haya destreza tecnológica (se controla por software)
        enchufe = SaacSistema.query.filter(SaacSistema.nombre.ilike('%enchufe%')).first()
        if enchufe and enchufe.id not in ids_acc_vistos:
            accesorios_referencia.append(enchufe)
            ids_acc_vistos.add(enchufe.id)

    if v_silla and pref['soporte'] and pref['soporte'].id not in ids_acc_vistos:
        accesorios_referencia.append(pref['soporte'])
        ids_acc_vistos.add(pref['soporte'].id)

    # --- GUARDADO EN HISTORIAL ---
    try:
        nombres_entradas_lista = [e.nombre for e in TipoEntrada.query.filter(TipoEntrada.id.in_(ids_entradas)).all()]
        resumen_txt = f"SISTEMAS: {', '.join([s.nombre for s in sistemas_finales])}"
        nuevo_historial = HistorialRecomendacion(
            nombre_paciente=nombre_usuario, fecha=datetime.now(),
            input_usuario={"vision": v_vision, "habla": v_habla, "resistencia": v_resistencia, "silla": v_silla, "entradas": nombres_entradas_lista},
            sistemas_recomenadados=resumen_txt
        )
        bd.session.add(nuevo_historial)
        bd.session.commit()
        h_id = nuevo_historial.id
    except:
        bd.session.rollback()
        h_id = None

    return render_template('recomendacion.html', 
                           sistemas=sistemas_finales, 
                           sistemas_preventivos=sistemas_preventivos, 
                           accesorios_referencia=accesorios_referencia, 
                           bancos_voz=bancos_voz_informativa, 
                           nombre_usuario=nombre_usuario, 
                           historial_id=h_id)

@app.route('/guardar-feedback', methods=['POST'])
def guardar_feedback():
    from sqlalchemy.orm.attributes import flag_modified
    h_id = request.form.get('historial_id')
    if h_id:
        fb = {k: request.form.get(k) for k in ['usa_actual', 'satisfaccion_actual', 'opcion_cambio', 'motivo_cambio', 'valoracion_general', 'comentarios_adicionales']}
        reg = HistorialRecomendacion.query.get(h_id)
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