import os
import string
import random
from datetime import datetime
from flask import Flask, render_template, request, redirect, url_for, jsonify
from modelos import SaacSistema, Idioma, SistemaRequisitoFuncional, TipoEntrada, Plataforma, HistorialRecomendacion, EntornoUso, MetodoComunicacion
from extension import bd
from dotenv import load_dotenv
from sqlalchemy import or_

#Carga las variables de entorno desde el archivo .env (credenciales de BD)
load_dotenv()

app = Flask(__name__)

#CONFIGURACIÓN DE BASE DE DATOS
#Recupera la configuración de conexión desde las variables de entorno para evitar filtrar contraseña
usuario = os.getenv('DB_USER')
contrasena = os.getenv('DB_PASSWORD')
host = os.getenv('DB_HOST')
puerto = os.getenv('DB_PORT')
base = os.getenv('DB_NAME')

app.config['SQLALCHEMY_DATABASE_URI'] = f'postgresql://{usuario}:{contrasena}@{host}:{puerto}/{base}'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
bd.init_app(app)

#Función que crea un id único aleatorio a cada usuario para conseguir inonimización
def generar_id_anonimo():
    caracteres = string.ascii_uppercase + string.digits
    return f"PAC-{''.join(random.choice(caracteres) for _ in range(6))}"

#RUTAS DE NAVEGACIÓN
#Ruta a pestaña de inicio con info general
@app.route('/')
def informar(): 
    return render_template("informacion.html")

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

#LÓGICA PRINCIPAL DE RECOMENDACIÓN. Recibe el cuestionario contestado, aplica un algoritmo de filtrado y genera recomendación
@app.route('/recomendar', methods=['POST'])
def recomendar():
    nombre_usuario = generar_id_anonimo()

    #CAPTURA DE DATOS
    #IDS de las opciones seleccionadas en el cuestionario para idiomas, entradas, plataformas y métodos en forma de listas int
    ids_idiomas = [int(x) for x in request.form.getlist('idioma_ids')]
    ids_entradas = [int(x) for x in request.form.getlist('entrada_ids')]
    ids_plataformas = [int(x) for x in request.form.getlist('plataforma_ids')]
    ids_metodos_usuario = [int(x) for x in request.form.getlist('alfabetizacion_ids')]

    #Niveles funcionales del usuario en escala numérica
    v_vision = int(request.form.get('vision', 0))
    v_audicion = int(request.form.get('audicion', 0))
    v_habla = int(request.form.get('habla', 0))
    v_resistencia = int(request.form.get('resistencia', 0))
    v_tecnologia = int(request.form.get('tecnologia', 0))
    v_autonomia_nivel = int(request.form.get('independencia', 0))

    #Datos adicionales sobre el entorno, silla y si es un paciente real o una prueba
    v_entorno = request.form.get('entorno_principal', 'No definido')
    v_silla = request.form.get('usa_silla') == 'true'
    v_es_real = request.form.get('es_real') == 'true'

    #INICIALIZACIÓN DE LISTAS DE RESULTADOS
    sistemas_finales = [] #Lista de sistemas válidos para recomendar directamente
    sistemas_preventivos = [] #Lista de sistemas que se pueden recomendar de forma preventiva (para facilitar la curva de aprendizaje)
    accesorios_referencia = [] #Lista de accesorios asociados
    ids_acc_vistos = set() #Control de duplicados en accesorios (si es complementario a varios SAAC sugeridos vale con que lo recomiende una vez)
    bancos_voz_final = [] #Lista con Voice Banking

    #LÓGICA DE FILTRADO BASE (SQL)
    consulta = SaacSistema.query.outerjoin(SistemaRequisitoFuncional)
    
    #Filtros clínicos (El nivel del usuario debe ser mayor o igual al mínimo requerido por el sistema)
    campos_clinicos = [(SaacSistema.fatiga_fisica, v_resistencia),
        (SistemaRequisitoFuncional.nivel_visual_min, v_vision), 
        (SistemaRequisitoFuncional.nivel_tecnologico_min, v_tecnologia), 
        (SistemaRequisitoFuncional.nivel_auditivo_min, v_audicion),
        (SistemaRequisitoFuncional.nivel_habla_min, v_habla)]
    
    for columna, valor in campos_clinicos:
        consulta = consulta.filter(columna <= valor)

    #Ejecuta el filtro anterior y se obtienen los resultados preliminares
    resultados_preliminares = consulta.all()

    #PERIFÉRICOS 
    #Busca dispositivos por nombre para agregarlos como periféricos
    todos_sist = SaacSistema.query.all()
    def buscar_hardware(keyword):
        return next((x for x in todos_sist if keyword.lower() in x.nombre.lower() and x.categoria == 'hardware'), None)

    #Lista con los recomendados más habitualmente
    pref = {'eye_tracker': buscar_hardware('Eye tracker'),
        'ipad': buscar_hardware('iPad'),
        'tablet': buscar_hardware('Tablet Android'),
        'laptop': buscar_hardware('Ordenador Portátil'),}

    #Obtiene el ID de control ocular para los filtros
    ent_ojos = TipoEntrada.query.filter(TipoEntrada.nombre.ilike('%ojos%')).first()
    id_ojos = ent_ojos.id

    #BUCLE DE FILTRADO DETALLADO a partir de los preliminares
    for s in resultados_preliminares:
        #Filtro de idiomas, el sistema debe tener al menos uno de los idiomas seleccionados
        if ids_idiomas and not any(i.id in ids_idiomas for i in s.idiomas): continue
        
        #Filtro de plataformas (Paneles físicos pasan siempre, apps se filtran según la plataforma que haya elegido el usaurio)
        if ids_plataformas:
            s_plats_ids = [p.id for p in s.plataformas]
            plats_nombres = [p.nombre.lower() for p in s.plataformas]
            
            #Determinamos si es un sistema físico/papel:
            es_sistema_fisico = (
                len(s_plats_ids) == 0 or 
                any(n in ["panel físico", "papel", "baja tecnología"] for n in plats_nombres) or
                any(keyword in s.nombre.lower() for keyword in ['panel', 'tablero', 'cuaderno', 'etran'])
            )

            #Si NO es físico y NO coincide con la plataforma del usuario, lo descartamos
            if not es_sistema_fisico:
                if not any(p_id in s_plats_ids for p_id in ids_plataformas): continue

        #FILTRO DE MÉTODOS (Alfabeto/Pictogramas)
        if ids_metodos_usuario:
            metodos_sistema_ids = [m.id for m in s.metodos]
            #Si el sistema tiene métodos definidos, debe coincidir con al menos uno del usuario
            if metodos_sistema_ids and not any(m_id in ids_metodos_usuario for m_id in metodos_sistema_ids): continue

        #Filtro de entradas, el sistema debe aceptar al menos uno de los métodos de entrada elegidos 
        if ids_entradas and s.entradas:
            if not any(e.id in ids_entradas for e in s.entradas): continue

        #ASIGNACIÓN DE ACCESORIOS Y LÓGICA PREVENTIVA
        #Atributos para mejor visualización
        s.nota_clinica = ""
        s.accesorio_vinculado = None
        s.dispositivo_base = None

        #Asignar dispositivo base según plataforma asignada del sistema
        p_nombres_list = [p.nombre for p in s.plataformas]
        if 'iOS' in p_nombres_list: s.dispositivo_base = pref['ipad']
        elif 'Android' in p_nombres_list: s.dispositivo_base = pref['tablet']
        elif 'Windows' in p_nombres_list: s.dispositivo_base = pref['laptop']

        s_entradas_ids = [e.id for e in s.entradas]
        
        #Lógica para control ocular
        if id_ojos in s_entradas_ids:
            if id_ojos not in ids_entradas: 
                #Filtro para evitar recomendar hardware como preventivos y paneles fisicos
                es_software = s.categoria == 'sistema' and not any(kw in s.nombre.lower() for kw in ['panel', 'tablero', 'cuaderno', 'etran'])
                
                #Solo se recomienda como preventivo si es software y requiere hardware extra (eye tracker)
                #El eye tracker es con lo que más les cuesta familiarizarse y a la vez lo más usado en etapas avanzadas
                if es_software and s.requiere_hardware_extra:
                    s.accesorio_vinculado = pref['eye_tracker']
                    s.nota_clinica = "RECOMENDACIÓN PREVENTIVA: Entrenamiento temprano para el futuro control ocular."
                    sistemas_preventivos.append(s)
                    continue #No se añade a la lista de recomendaciones directas para que no salga duplicado
                else:
                    continue 
            else:
                #Si el usuario SÍ marcó ojos, vinculamos el accesorio si el sistema lo requiere
                if s.requiere_hardware_extra: 
                    s.accesorio_vinculado = pref['eye_tracker']

        #Si llegamos aquí y es de la categoria sistema (no es hardware), se añade a la lista final
        if s.categoria == 'sistema':
            sistemas_finales.append(s)

    #PREPARAR LISTAS PARA HTML
    #Lista de sistemas recomendados directamente
    recomendados = [s for s in sistemas_finales if s.categoria == 'sistema']
    
    #Recopila accesorios únicos (dispositivo base + accesorio vinculado)
    for s in recomendados:
        for extra in [s.dispositivo_base, s.accesorio_vinculado]:
            if extra and extra.id not in ids_acc_vistos:
                accesorios_referencia.append(extra)
                ids_acc_vistos.add(extra.id)

    #Si el usuario puede hablar se muestran todos
    bancos_voz_final = [s for s in sistemas_finales if s.categoria == 'servicio']
    if not bancos_voz_final and v_habla >= 2:
        bancos_voz_final = SaacSistema.query.filter(SaacSistema.categoria == 'servicio').all()

    #GUARDAR HISTORIAL
    #ID del registro (usado más adelante para el feedback)
    h_id = None

    #Recupera los objetos completos a partir de los IDs seleccionados
    metodos_obj = MetodoComunicacion.query.filter(MetodoComunicacion.id.in_(ids_metodos_usuario)).all()
    metodos_nombres = [m.nombre for m in metodos_obj]
    idiomas_obj = Idioma.query.filter(Idioma.id.in_(ids_idiomas)).all()
    plataformas_obj = Plataforma.query.filter(Plataforma.id.in_(ids_plataformas)).all()
    metodos_obj = MetodoComunicacion.query.filter(MetodoComunicacion.id.in_(ids_metodos_usuario)).all()
    entradas_obj = TipoEntrada.query.filter(TipoEntrada.id.in_(ids_entradas)).all()
    nombres_entradas = [e.nombre for e in entradas_obj]

    #Diccionario con el perfil completo del usuario para guardarlo en JSON
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

    #Texto para mejorar legilibilidad en visualización
    texto_recomendacion = f"SISTEMAS: {', '.join([s.nombre for s in recomendados])}"
    if accesorios_referencia:
        texto_recomendacion += f" | ACCESORIOS: {', '.join([a.nombre for a in accesorios_referencia])}"

    #Se crea el registro en el historial
    nuevo_historial = HistorialRecomendacion(
        nombre_paciente=nombre_usuario,
        fecha=datetime.now(),
        input_usuario=datos_completos,
        sistemas_recomendados=texto_recomendacion,
        es_real=v_es_real)
        
    #Se guarda en BD 
    bd.session.add(nuevo_historial)
    bd.session.commit()
    h_id = nuevo_historial.id

    #Renderizado página de resultados
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