import os
from flask import Flask, render_template, request
from dotenv import load_dotenv
from extension import bd
import modelos
from modelos import SaacSistema, Idioma, SistemaRequisitoFuncional, TipoEntrada, Plataforma
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

@app.route('/cuestionario')
def cuestionario():
    idiomas = Idioma.query.all()
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
    ids_entradas = [int(x) for x in request.form.getlist('entrada_ids') if x]
    
    try:
        v_presupuesto = float(request.form.get('presupuesto', 999999))
    except:
        v_presupuesto = 999999.0

    # 2. Capturar Capacidades
    v_vision = int(request.form.get('vision', 3))
    v_cognicion = int(request.form.get('cognicion', 3))
    v_tecno = int(request.form.get('tecnologia', 3))

    # --- CONSULTA BASE ---
    consulta = SaacSistema.query.outerjoin(SistemaRequisitoFuncional)

    # FILTRO: Presupuesto
    consulta = consulta.filter(SaacSistema.coste_min <= v_presupuesto)

    # FILTRO: Capacidades (Acepta nivel solicitado o sistemas sin requisitos definidos)
    consulta = consulta.filter(
        or_(SistemaRequisitoFuncional.nivel_visual_min <= v_vision, SistemaRequisitoFuncional.nivel_visual_min == None),
        or_(SistemaRequisitoFuncional.nivel_cognitivo_min <= v_cognicion, SistemaRequisitoFuncional.nivel_cognitivo_min == None),
        or_(SistemaRequisitoFuncional.nivel_tecnologico_min <= v_tecno, SistemaRequisitoFuncional.nivel_tecnologico_min == None)
    )

    # FILTRO: Entradas (Selección dinámica)
    if ids_entradas:
        consulta = consulta.filter(SaacSistema.entradas.any(TipoEntrada.id.in_(ids_entradas)))

    # EJECUTAR CONSULTA
    resultados = consulta.all()

    # --- LÓGICA DE RECOMENDACIÓN INTELIGENTE (Post-procesamiento) ---
    sistemas_finales = [s for s in resultados if not s.es_accesorio]
    accesorios_brutos = [s for s in resultados if s.es_accesorio]
    accesorios_finales = []

    for acc in accesorios_brutos:
        nombre_acc = acc.nombre.lower()
        
        # Caso A: Eye Tracker
        if "eye tracker" in nombre_acc:
            if 1 not in ids_entradas:  # Solo si NO puede usar las manos
                acc.nota_clinica = "Recomendado como acceso principal por mirada para alta discapacidad motora."
                accesorios_finales.append(acc)
        
        # Caso B: Gafas con Puntero (Referencia ELA Andalucía)
        elif "gafas" in nombre_acc:
            if 3 in ids_entradas:  # Solo si puede mover la CABEZA
                acc.nota_clinica = "Eficacia clínica probada (ELA Andalucía): Ideal para control cefálico con tableros físicos."
                accesorios_finales.append(acc)
        
        # Caso C: Puntero Láser Manual
        elif "puntero" in nombre_acc and "gafas" not in nombre_acc:
            if 1 in ids_entradas:  # Si puede usar las MANOS
                acc.nota_clinica = "Soporte de baja tecnología para señalar con precisión sin fatiga táctil."
                accesorios_finales.append(acc)
        
        # Otros accesorios genéricos
        else:
            accesorios_finales.append(acc)

    print(f"--- DEBUG: {nombre} ---")
    print(f"Sistemas: {len(sistemas_finales)} | Accesorios: {len(accesorios_finales)}")

    return render_template('sistemas.html', 
                           sistemas=sistemas_finales, 
                           accesorios=accesorios_finales,
                           nombre_usuario=nombre)

if __name__ == '__main__':
    app.run(debug=True)
    
#python backend/app.py
#http://127.0.0.1:5000/cuestionario