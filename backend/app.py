import os
import string
import random
from datetime import datetime
from flask import Flask, render_template, request, redirect, url_for, jsonify
from flask_talisman import Talisman
from backend.modelos import SaacSistema, Idioma, SistemaRequisitoFuncional, TipoEntrada, Plataforma, HistorialRecomendacion, EntornoUso, MetodoComunicacion
from backend.extension import bd
from dotenv import load_dotenv
from sqlalchemy import or_

import os
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

# Definimos una política CSP equilibrada para que permita tus estilos locales
csp_config = {
    'default-src': '\'self\'',
    # Permite tus estilos locales (estilos.css) y estilos en línea si los usas
    'style-src': [
        '\'self\'',
        '\'unsafe-inline\'' 
    ],
    # Permite tus scripts locales de JavaScript
    'script-src': [
        '\'self\'',
        '\'unsafe-inline\''
    ]
}

# Inicializamos Talisman con las directivas de OWASP
Talisman(
    app,
    force_https=True,                # 1. Redirección automática HTTP -> HTTPS
    strict_transport_security=True,  # 2. HSTS (Forzar HTTPS en el navegador)
    content_security_policy=csp_config, # 3. CSP (Previene ataques XSS e inyecciones)
    session_cookie_secure=True,      # Asegura que las cookies solo viajen por HTTPS
    session_cookie_http_only=True    # Previene que scripts maliciosos roben tus cookies
)

# CONFIGURACIÓN DE BASE DE DATOS 
# Primero intenta obtener la URL completa (la que da Render)
# Si no existe, construye la URL con las variables locales del .env
url_nube = os.getenv('DATABASE_URL')

if url_nube:
    if url_nube.startswith("postgres://"):
        url_nube = url_nube.replace("postgres://", "postgresql://", 1)
    app.config['SQLALCHEMY_DATABASE_URI'] = url_nube
else:
    usuario = os.getenv('DB_USER')
    contrasena = os.getenv('DB_PASSWORD')
    host = os.getenv('DB_HOST')
    puerto = os.getenv('DB_PORT')
    base = os.getenv('DB_NAME')
    app.config['SQLALCHEMY_DATABASE_URI'] = f'postgresql://{usuario}:{contrasena}@{host}:{puerto}/{base}'

app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
bd.init_app(app)

with app.app_context():
    try:
        bd.create_all()
        print("Tablas creadas exitosamente.")
    except Exception as e:
        print(f"Error al crear las tablas: {e}")

#Función que crea un id único aleatorio a cada usuario para conseguir inonimización
def generar_id_anonimo():
    caracteres = string.ascii_uppercase + string.digits
    return f"PAC-{''.join(random.choice(caracteres) for _ in range(6))}"

#RUTAS DE NAVEGACIÓN
#Ruta a pestaña de inicio con info general
@app.route('/')
def informar(): 
    return render_template("inicio.html")

#Ruta a pestaña con info sobre ELA
@app.route('/ELA')
def info_ela(): 
    return render_template("ELA.html")

#Ruta a pestaña con info sobre SAAC
@app.route('/SAAC')
def info_saac(): 
    return render_template("SAAC.html")

#Ruta a pestaña con cuestionario. Carga desde la bd las listas de idiomas, entradas y plataformas 
@app.route('/cuestionario')
def cuestionary():
    idiomas = Idioma.query.order_by(Idioma.id).all() 
    entradas = TipoEntrada.query.all()
    plataformas = Plataforma.query.all()
    return render_template('cuestionario.html', idiomas=idiomas, entradas=entradas, plataformas=plataformas)

#Ruta a pestaña con información legal (tratamiento, almacenamiento y procesado de datos sensibles)
@app.route('/info_legal')
def info_legal():
    return render_template('info_legal.html')

#LÓGICA PRINCIPAL DE RECOMENDACIÓN. Recibe el cuestionario contestado, aplica un algoritmo de filtrado y genera recomendación
@app.route('/recomendar', methods=['POST'])
def determinar_recomendacion():
    nombre_usuario = generar_id_anonimo()

    # CAPTURA DE DATOS
    # IDS de las opciones seleccionadas en el cuestionario para idiomas, entradas, plataformas y métodos en forma de listas int
    ids_idiomas = [int(x) for x in request.form.getlist('idioma_ids')]
    ids_entradas = [int(x) for x in request.form.getlist('entrada_ids')]
    ids_plataformas = [int(x) for x in request.form.getlist('plataforma_ids')]
    ids_metodos_usuario = [int(x) for x in request.form.getlist('alfabetizacion_ids')]

    # Niveles funcionales del usuario en escala numérica
    v_vision = int(request.form.get('vision', 0))
    v_audicion = int(request.form.get('audicion', 0))
    v_habla = int(request.form.get('habla', 0))
    v_resistencia = int(request.form.get('resistencia', 0))
    v_tecnologia = int(request.form.get('tecnologia', 0))
    v_autonomia_nivel = int(request.form.get('independencia', 0))

    # Datos adicionales sobre el entorno, silla y si es un paciente real o una prueba
    v_entorno = request.form.get('entorno_principal', 'No definido')
    v_silla = request.form.get('usa_silla') == 'true'
    # Captura limpia de PACIENTE REAL (True si está marcado, False si no)
    # Captura limpia de PACIENTE REAL (Compara si el string es exactamente 'true')
    v_es_real = request.form.get('es_real') == 'true'

    # Captura limpia de AUTORIZA INVESTIGACIÓN
    v_autoriza_investigacion = request.form.get('autoriza_investigacion') == 'true'

    # INICIALIZACIÓN DE LISTAS DE RESULTADOS
    sistemas_finales = [] #Lista de sistemas válidos para recomendar directamente
    sistemas_preventivos = [] #Lista de sistemas que se pueden recomendar de forma preventiva (para facilitar la curva de aprendizaje)
    accesorios_referencia = [] #Lista de accesorios asociados
    ids_acc_vistos = set() #Control de duplicados en accesorios (si es complementario a varios SAAC sugeridos vale con que lo recomiende una vez)
    bancos_voz_final = [] #Lista con Voice Banking

    # Identificación de IDs críticos para filtros inteligentes (Ojos y Manos)
    ent_ojos = TipoEntrada.query.filter(TipoEntrada.nombre.ilike('%ojos%')).first()
    id_ojos = ent_ojos.id if ent_ojos else None
    ent_manos = TipoEntrada.query.filter(TipoEntrada.nombre.ilike('%manos%')).first()
    id_manos = ent_manos.id if ent_manos else None

    # LÓGICA DE FILTRADO BASE (SQL)
    consulta = SaacSistema.query.outerjoin(SistemaRequisitoFuncional)
    
    # Filtros clínicos (El nivel del usuario debe ser mayor o igual al mínimo requerido por el sistema)
    campos_clinicos = [(SaacSistema.fatiga_fisica, v_resistencia),
        (SistemaRequisitoFuncional.nivel_visual_min, v_vision), 
        (SistemaRequisitoFuncional.nivel_tecnologico_min, v_tecnologia), 
        (SistemaRequisitoFuncional.nivel_auditivo_min, v_audicion),
        (SistemaRequisitoFuncional.nivel_habla_min, v_habla)]
    
    for columna, valor in campos_clinicos:
        consulta = consulta.filter(columna <= valor)

    # Ejecuta el filtro anterior y se obtienen los resultados preliminares
    resultados_preliminares = consulta.all()

    # FUNCIÓN RECURSIVA PARA OBTENER PERIFÉRICOS (NUEVO)
    # Busca en la tabla de asociación sistema_dependencia y añade accesorios "tirando del hilo" (ej: Software -> Tablet -> Soporte)
    def obtener_perifericos_recursivo(sistema_u_objeto, lista_para_llenar):
        for acc in sistema_u_objeto.hardware_requerido:
            # FILTRO DE PRECISIÓN TÁCTIL: Solo recomienda Lápiz o Guantes si el usuario puede usar las manos
            es_accesorio_tactil = any(k in acc.nombre.lower() for k in ['lápiz', 'guante'])
            if es_accesorio_tactil and (id_manos not in ids_entradas):
                continue

            # FILTRO DE COHERENCIA DE PLATAFORMA PARA HIJOS:
            # Si el accesorio tiene plataformas asignadas, solo lo incluimos si coincide con la selección del usuario
            acc_plats_ids = [p.id for p in acc.plataformas]
            if acc_plats_ids and ids_plataformas:
                if not any(p_id in acc_plats_ids for p_id in ids_plataformas):
                    continue

            # Lo añadimos a la lista específica de este sistema (para que salga en la tabla)
            if acc not in lista_para_llenar:
                lista_para_llenar.append(acc)

            # Lo añadimos a la lista global de referencia (para evitar duplicados en la tabla inferior)
            if acc.id not in ids_acc_vistos:
                ids_acc_vistos.add(acc.id)
                accesorios_referencia.append(acc)

            # Llamada recursiva para encontrar dependencias del accesorio (Cascada)
            obtener_perifericos_recursivo(acc, lista_para_llenar)

    # BUCLE DE FILTRADO DETALLADO a partir de los preliminares
    for s in resultados_preliminares:
        # Inicializamos los atributos para el HTML
        s.accesorios_totales = []
        s.nota_clinica = ""

        # Filtro de idiomas, el sistema debe tener al menos uno de los idiomas seleccionados
        if ids_idiomas and not any(i.id in ids_idiomas for i in s.idiomas): continue
        
        # Filtro de plataformas (Corregido para ser estricto con los Packs y Paneles)
        if ids_plataformas:
            s_plats_ids = [p.id for p in s.plataformas]
            # Si el sistema tiene plataformas asignadas, comprobamos coincidencia estricta
            if s_plats_ids:
                if not any(p_id in s_plats_ids for p_id in ids_plataformas):
                    continue
            # Si el sistema no tiene ninguna plataforma asignada (y es categoría sistema), no debería pasar el filtro
            elif s.categoria == 'sistema':
                continue

        # FILTRO DE MÉTODOS (Alfabeto/Pictogramas)
        if ids_metodos_usuario:
            metodos_sistema_ids = [m.id for m in s.metodos]
            # Si el sistema tiene métodos definidos, debe coincidir con al menos uno del usuario
            if metodos_sistema_ids and not any(m_id in ids_metodos_usuario for m_id in metodos_sistema_ids): continue

        # Filtro de entradas, el sistema debe aceptar al menos uno de los métodos de entrada elegidos 
        if ids_entradas and s.entradas:
            if not any(e.id in ids_entradas for e in s.entradas): continue

        # ASIGNACIÓN DE ACCESORIOS Y LÓGICA PREVENTIVA
        s_entradas_ids = [e.id for e in s.entradas]
        
        # Lógica para control ocular preventivo
        if id_ojos and id_ojos in s_entradas_ids and id_ojos not in ids_entradas:
            # Solo se recomienda como preventivo si es software y requiere eye tracker (según BD)
            tiene_eye_tracker = any('eye tracker' in h.nombre.lower() for h in s.hardware_requerido)
            
            if s.categoria == 'sistema' and tiene_eye_tracker:
                s.nota_clinica = "RECOMENDACIÓN PREVENTIVA: Entrenamiento temprano para el futuro control ocular."
                sistemas_preventivos.append(s)
                # Buscamos periféricos del preventivo para mostrarlos en la lista de referencia y en su objeto
                obtener_perifericos_recursivo(s, s.accesorios_totales)
                continue # No se añade a la lista de recomendaciones directas para que no salga duplicado
            else:
                continue 
        
        # Si llegamos aquí y es de la categoria sistema (no es hardware), se añade a la lista final
        if s.categoria == 'sistema':
            sistemas_finales.append(s)
            # Activamos la búsqueda en cascada de periféricos para este sistema
            obtener_perifericos_recursivo(s, s.accesorios_totales)

    # PREPARAR LISTAS PARA HTML
    # Lista de sistemas recomendados directamente
    recomendados = sistemas_finales
    
    # Si el usuario puede hablar se muestran todos
    bancos_voz_final = [s for s in sistemas_finales if s.categoria == 'servicio']
    if not bancos_voz_final and v_habla >= 2:
        bancos_voz_final = SaacSistema.query.filter(SaacSistema.categoria == 'servicio').all()

    # CONTROL DE HISTORIAL Y ALMACENAMIENTO DE DATOS ANÓNIMOS
    h_id = None

    # El registro histórico solo se procesa y ejecuta si existe consentimiento explícito del participante
    if v_autoriza_investigacion:
        # Recupera los objetos completos a partir de los IDs seleccionados
        idiomas_obj = Idioma.query.filter(Idioma.id.in_(ids_idiomas)).all()
        plataformas_obj = Plataforma.query.filter(Plataforma.id.in_(ids_plataformas)).all()
        metodos_obj = MetodoComunicacion.query.filter(MetodoComunicacion.id.in_(ids_metodos_usuario)).all()
        entradas_obj = TipoEntrada.query.filter(TipoEntrada.id.in_(ids_entradas)).all()
        nombres_entradas = [e.nombre for e in entradas_obj]

        # Diccionario con el perfil completo del usuario para guardarlo en JSON
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
            "metodo_pref": ", ".join([m.nombre for m in metodos_obj]) if metodos_obj else "Sin preferencia"}

        # Texto para mejorar legibilidad en visualización del historial
        texto_recomendacion = f"SISTEMAS: {', '.join([s.nombre for s in recomendados])}"
        if accesorios_referencia:
            texto_recomendacion += f" | ACCESORIOS: {', '.join([a.nombre for a in accesorios_referencia])}"

        # Se crea el registro en el historial
        nuevo_historial = HistorialRecomendacion(
            nombre_paciente=nombre_usuario,
            fecha=datetime.now(),
            input_usuario=datos_completos,
            sistemas_recomendados=texto_recomendacion,
            es_real=v_es_real if v_autoriza_investigacion else False # Forzamos False si no hay autorización
)
            
        # Se guarda en BD 
        bd.session.add(nuevo_historial)
        bd.session.commit()
        h_id = nuevo_historial.id

    # Renderizado página de resultados
    return render_template('recomendacion.html', 
                           nombre_usuario=nombre_usuario,
                           sistemas=recomendados, 
                           accesorios_referencia=accesorios_referencia,
                           sistemas_preventivos=sistemas_preventivos,
                           bancos_voz=bancos_voz_final,
                           mostrar_respaldo=True,
                           historial_id=h_id)

#Ruta de feedback. Permite al usuario mandar su opinión
#Recibe el formulario de feedback y lo asocia con el registro del historial correspondiente mediante el ID
@app.route('/guardar-feedback', methods=['POST'])
def guardar_feedback():
    from sqlalchemy.orm.attributes import flag_modified
    h_id = request.form.get('historial_id')
    if h_id:
        #Diccionario de feedback con todos los campos del formulario
        fb = {k: request.form.get(k) for k in ['usa_actual', 'satisfaccion_actual', 'opcion_cambio', 'motivo_cambio', 'valoracion_general', 'comentarios_adicionales']}
        reg = bd.session.get(HistorialRecomendacion, h_id)
        if reg:
            reg.feedback = fb
            flag_modified(reg, "feedback")
            bd.session.commit()
    return render_template("gracias_feedback.html")

#Ruta a la pestaña de administración del historial. Los registros se guardan ordenados del más reciente al más antiguo
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