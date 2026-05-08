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

# --- CONFIGURACIÓN ---
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

# --- RUTAS DE INFORMACIÓN ---
@app.route('/')
def informar(): return render_template("informacion.html")

@app.route('/ELA')
def info_ela(): return render_template("ELA.html")

@app.route('/SAAC')
def info_saac(): return render_template("SAAC.html")

# --- CUESTIONARIO Y LÓGICA ---
@app.route('/cuestionario')
def cuestionary():
    idiomas = Idioma.query.order_by(Idioma.id).all() 
    entradas = TipoEntrada.query.all()
    plataformas = Plataforma.query.all()
    return render_template('cuestionario.html', idiomas=idiomas, entradas=entradas, plataformas=plataformas)

@app.route('/recomendar', methods=['POST'])
def recomendar():
    # 1. Capturar datos
    nombre_usuario = generar_id_anonimo() 
    ids_idiomas = [int(x) for x in request.form.getlist('idioma_ids') if x]
    ids_entradas = [int(x) for x in request.form.getlist('entrada_ids') if x]
    ids_plataformas = [int(x) for x in request.form.getlist('plataforma_ids') if x]
    
    v_silla = request.form.get('usa_silla') == 'true'
    v_vision = int(request.form.get('vision', 3))
    v_habla = int(request.form.get('habla', 3))
    v_resistencia = int(request.form.get('resistencia', 3))
    v_independencia = int(request.form.get('independencia', 3))
    
    ids_alfabetizacion = [int(x) for x in request.form.getlist('alfabetizacion_ids') if x]
    v_alfabetizacion = max(ids_alfabetizacion) if ids_alfabetizacion else 3
    v_tecnologia = int(request.form.get('tecnologia', 3))
    v_audicion = int(request.form.get('audicion', 3))

    # --- 2. BÚSQUEDA VOICE BANKING ---
    bancos_voz_informativa = []
    if v_habla >= 2:
        bancos_voz_informativa = SaacSistema.query.filter(or_(
            SaacSistema.nombre.ilike('%voice%'), 
            SaacSistema.nombre.ilike('%banking%'), 
            SaacSistema.nombre.ilike('%vocalid%'), 
            SaacSistema.nombre.ilike('%model%'), 
            SaacSistema.nombre.ilike('%myownvoice%')
        )).all()

    # --- 3. CONSULTA FILTRADA ---
    consulta = SaacSistema.query.outerjoin(SistemaRequisitoFuncional)
    consulta = consulta.filter(or_(SaacSistema.fatiga_fisica <= v_resistencia, SaacSistema.fatiga_fisica == None))

    campos = [
        (SistemaRequisitoFuncional.nivel_visual_min, v_vision), 
        (SistemaRequisitoFuncional.nivel_cognitivo_min, v_alfabetizacion), 
        (SistemaRequisitoFuncional.nivel_tecnologico_min, v_tecnologia), 
        (SistemaRequisitoFuncional.nivel_auditivo_min, v_audicion), 
        (SistemaRequisitoFuncional.nivel_habla_min, v_habla)
    ]
    
    for columna, valor in campos:
        consulta = consulta.filter(or_(columna <= valor, columna == None))

    if v_independencia == 0:
        pass

    if ids_idiomas:
        consulta = consulta.filter(SaacSistema.idiomas.any(Idioma.id.in_(ids_idiomas)))
    
    if ids_entradas:
        consulta = consulta.filter(SaacSistema.entradas.any(TipoEntrada.id.in_(ids_entradas)))
    
    if ids_plataformas:
        consulta = consulta.filter(SaacSistema.plataformas.any(Plataforma.id.in_(ids_plataformas)))

    resultados = consulta.all()

    # --- 4. PROCESAMIENTO ---
    sistemas_finales = []
    sistemas_preventivos = [] 
    accesorios_referencia = []
    ids_acc_vistos = set() 
    
    todos_sist = SaacSistema.query.all()
    
    def buscar_pref(keyword):
        return next((x for x in todos_sist if keyword.lower() in x.nombre.lower()), None)

    pref = {
        'eye_tracker': buscar_pref('tracker') or buscar_pref('ocul'),
        'soporte': buscar_pref('soporte'),
        'ipad': buscar_pref('ipad'),
        'tablet': buscar_pref('tablet android'),
        'laptop': buscar_pref('portátil') or buscar_pref('ordenador')
    }

    nombres_excluidos = ['tracker', 'puntero', 'soporte', 'conmutador', 'pedal', 'guante', 'lápiz', 'ratón', 'ipad', 'tablet', 'portátil', 'alexa', 'google home', 'hub', 'enchufe', 'bjoy', 'chin']

    for s in resultados:
        if any(kw in s.nombre.lower() for kw in ['voice', 'banking']) or any(kw in s.nombre.lower() for kw in nombres_excluidos):
            continue

        s.nota_clinica = ""
        s.accesorio_vinculado = None 
        s.dispositivo_base = None 
        
        plats_s = [p.nombre for p in s.plataformas]
        if 'iOS' in plats_s: s.dispositivo_base = pref['ipad']
        elif 'Android' in plats_s: s.dispositivo_base = pref['tablet']
        elif 'Windows' in plats_s: s.dispositivo_base = pref['laptop']

        ids_s = [e.id for e in s.entradas]
        s.peso_esfuerzo = 1 if 1 in ids_s else 5 if 2 in ids_s else 3

        if (2 in ids_s and 2 not in ids_entradas):
            if not s.requiere_interlocutor:
                s.accesorio_vinculado = pref['eye_tracker']
            s.nota_clinica = "RECOMENDACIÓN PREVENTIVA: Se sugiere iniciar entrenamiento precoz con mirada para facilitar la comunicación futura."
            sistemas_preventivos.append(s)
        else:
            if 2 in ids_s and 2 in ids_entradas and not s.requiere_interlocutor:
                s.accesorio_vinculado = pref['eye_tracker']
            
            if s.requiere_interlocutor:
                s.nota_clinica += "Sistema de baja tecnología: requiere el apoyo de un interlocutor."

            if v_silla and s.admite_anclaje:
                s.nota_clinica += " | Requiere soporte de fijación a silla."
            
            sistemas_finales.append(s)

        if s.accesorio_vinculado and 'tracker' in s.accesorio_vinculado.nombre.lower():
            aviso_entorno = (
                " | CONFIGURACIÓN AMBIENTAL: Para un rastreo preciso, evite la luz solar directa sobre la pantalla "
                "y apague dispositivos electrónicos cercanos (como TV) que puedan interferir con los infrarrojos."
            )
            s.nota_clinica += aviso_entorno

    sistemas_finales.sort(key=lambda x: x.peso_esfuerzo)
    sistemas_preventivos.sort(key=lambda x: x.peso_esfuerzo)

    for s in sistemas_finales:
        for extra in [s.dispositivo_base, s.accesorio_vinculado]:
            if extra and extra.id not in ids_acc_vistos:
                accesorios_referencia.append(extra)
                ids_acc_vistos.add(extra.id)

    if v_silla and pref['soporte'] and pref['soporte'].id not in ids_acc_vistos:
        accesorios_referencia.append(pref['soporte'])
        ids_acc_vistos.add(pref['soporte'].id)

    # --- 5. GUARDADO ---
    try:
        # datetime.now() utiliza la hora local de tu ordenador
        hora_local = datetime.now()

        nombres_entradas = [e.nombre for e in TipoEntrada.query.filter(TipoEntrada.id.in_(ids_entradas)).all()]
        resumen = f"SISTEMAS: {', '.join([s.nombre for s in sistemas_finales])} | PREVENTIVOS: {', '.join([s.nombre for s in sistemas_preventivos])}"
        
        nuevo_historial = HistorialRecomendacion(
            nombre_paciente=nombre_usuario,
            fecha=hora_local,
            input_usuario={
                "vision": v_vision, "habla": v_habla, "resistencia": v_resistencia, 
                "silla": v_silla, "entradas": nombres_entradas, "autonomia": v_independencia
            },
            sistemas_recomendados=resumen 
        )
        bd.session.add(nuevo_historial)
        bd.session.commit()
        h_id = nuevo_historial.id
    except Exception as e:
        print(f"Error al guardar: {e}")
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

#python backend/app.py
#http://127.0.0.1:5000
#http://127.0.0.1:5000/admin_historial