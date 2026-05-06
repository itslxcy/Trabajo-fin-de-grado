import os
from flask import Flask, render_template, request, redirect, url_for
from modelos import SaacSistema, Idioma, SistemaRequisitoFuncional, TipoEntrada, Plataforma, HistorialRecomendacion
from extension import bd
from dotenv import load_dotenv
from sqlalchemy import or_

load_dotenv()

app = Flask(__name__)

# --- CONFIGURACIÓN DE LA BASE DE DATOS ---
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
    nombre_usuario = request.form.get('nombre')
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

    # --- 4. CONSULTA Y FILTROS ---
    consulta = SaacSistema.query.outerjoin(SistemaRequisitoFuncional)
    consulta = consulta.filter(SaacSistema.coste_min <= v_presupuesto)
    consulta = consulta.filter(SaacSistema.fatiga_fisica <= v_resistencia)

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

    # --- 5. LÓGICA DE PROCESAMIENTO Y VINCULACIÓN ---
    sistemas_finales = []
    accesorios_referencia = []
    bancos_voz_informativa = []
    ids_accesorios_vistos = set() 
    
    perifericos = {
        'eye_tracker': next((x for x in resultados if 'Eye tracker' in x.nombre), None),
        'soporte': next((x for x in resultados if 'Soporte' in x.nombre), None),
        'gafas': next((x for x in resultados if 'Gafas' in x.nombre), None),
        'laser': next((x for x in resultados if x.nombre == 'Puntero Láser'), None),
        'pufo': next((x for x in resultados if 'soplido' in x.nombre.lower()), None),
        'pedal': next((x for x in resultados if 'pedal' in x.nombre.lower()), None),
        'spec': next((x for x in resultados if 'Spec' in x.nombre), None),
        'chin': next((x for x in resultados if 'Chin' in x.nombre), None)
    }

    for s in resultados:
        nombre_low = s.nombre.lower()
        es_banco = any(kw in nombre_low for kw in ['modeltalker', 'myownvoice', 'vocalid'])
        if es_banco:
            if v_habla >= 2:
                bancos_voz_informativa.append(s)
            continue 

        es_hardware = any(kw in nombre_low for kw in ['tracker', 'puntero', 'gafas', 'soporte', 'conmutador', 'pedal', 'spec', 'chin', 'pufo'])
        if es_hardware:
            continue

        s.nota_clinica = ""
        s.accesorio_vinculado = None 
        s.prioridad_entorno = 0 
        
        if s.nombre in ['Grid 3', 'Verbo', 'TD Snap', 'Tallk', 'Look to learn', 'Communicator 5']:
            if 2 in ids_entradas: 
                s.accesorio_vinculado = perifericos['eye_tracker']
            elif 5 in ids_entradas:
                if v_resistencia <= 1: 
                    s.accesorio_vinculado = perifericos['pufo']
                elif v_resistencia == 2:
                    s.accesorio_vinculado = perifericos['chin']
                else:
                    s.accesorio_vinculado = perifericos['spec']

        if s.nombre in ['Panel alfabético', 'Panel pictogramas', 'SpeakBook']:
            if 3 in ids_entradas:
                s.accesorio_vinculado = perifericos['gafas']
            else:
                s.accesorio_vinculado = perifericos['laser']

        if v_silla and s.admite_anclaje:
            s.nota_clinica += "Requiere soporte de fijación a silla."
            if perifericos['soporte'] and perifericos['soporte'].id not in ids_accesorios_vistos:
                accesorios_referencia.append(perifericos['soporte'])
                ids_accesorios_vistos.add(perifericos['soporte'].id)
        
        if v_entorno == 'exterior':
            es_mirada = s.accesorio_vinculado and 'tracker' in s.accesorio_vinculado.nombre.lower()
            if es_mirada:
                s.nota_clinica += " | ADVERTENCIA: La mirada pierde precisión con luz solar."
                s.prioridad_entorno = 1 
            if not s.portable:
                s.prioridad_entorno = 1

        sistemas_finales.append(s)

    sistemas_finales.sort(key=lambda x: x.prioridad_entorno)
    for s in sistemas_finales:
        acc = s.accesorio_vinculado
        if acc and acc.id not in ids_accesorios_vistos:
            accesorios_referencia.append(acc)
            ids_accesorios_vistos.add(acc.id)

    # --- LÓGICA DE GUARDADO COMPLETA ---
    try:
        # Traducción de IDs a nombres para el historial
        nombres_entradas = [e.nombre for e in TipoEntrada.query.filter(TipoEntrada.id.in_(ids_entradas)).all()]
        nombres_plats = [p.nombre for p in Plataforma.query.filter(Plataforma.id.in_(ids_plataformas)).all()]

        nombres_sist = [s.nombre for s in sistemas_finales]
        nombres_acc = [acc.nombre for acc in accesorios_referencia]
        nombres_banc = [b.nombre for b in bancos_voz_informativa]
        
        resumen_final = f"SISTEMAS: {', '.join(nombres_sist)} | ACCESORIOS: {', '.join(nombres_acc)} | BANCOS: {', '.join(nombres_banc)}"
        
        datos_entrada = {
            "vision": v_vision,
            "audicion": v_audicion,
            "habla": v_habla,
            "cognicion": v_cognicion,
            "tecnologia": v_tecno,
            "resistencia": v_resistencia,
            "independencia": v_independencia,
            "presupuesto": v_presupuesto,
            "silla": v_silla,
            "entorno": v_entorno,
            "plataformas_nombres": nombres_plats,
            "entradas_nombres": nombres_entradas
        }

        nuevo_historial = HistorialRecomendacion(
            nombre_paciente=nombre_usuario,
            input_usuario=datos_entrada,
            sistemas_recomendados=resumen_final
        )

        bd.session.add(nuevo_historial)
        bd.session.commit()
        print(f"✅ Historial completo guardado para: {nombre_usuario}")

    except Exception as e:
        bd.session.rollback()
        print(f"❌ Error al guardar historial detallado: {e}")

    return render_template('recomendacion.html', 
                           sistemas=sistemas_finales, 
                           accesorios_referencia=accesorios_referencia,
                           bancos_voz=bancos_voz_informativa,
                           nombre_usuario=nombre_usuario)

@app.route('/admin/historial')
def ver_historial():
    registros = HistorialRecomendacion.query.order_by(HistorialRecomendacion.fecha.desc()).all()
    return render_template('admin_historial.html', registros=registros)

@app.route('/admin/limpiar-historial', methods=['POST'])
def limpiar_historial():
    try:
        HistorialRecomendacion.query.delete()
        bd.session.commit()
    except Exception as e:
        bd.session.rollback()
    return redirect(url_for('ver_historial'))

if __name__ == '__main__':
    app.run(debug=True)
    
#python backend/app.py
#http://127.0.0.1:5000
#http://127.0.0.1:5000/admin/historial