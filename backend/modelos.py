from datetime import datetime
from extension import bd

#TABLAS DE RELACIÓN MUCHOS A MUCHOS
#Relaciona sistemas SAAC con los entornos de uso donde son aplicables (ej: domicilio, colegio, trabajo)
sistema_entorno = bd.Table('sistema_entorno',
    bd.Column('sistema_id', bd.Integer, bd.ForeignKey('saac_sistema.id', ondelete='CASCADE'), primary_key=True),
    bd.Column('entorno_id', bd.Integer, bd.ForeignKey('entorno_uso.id', ondelete='CASCADE'), primary_key=True))

#Relaciona sistemas SAAC con los tipos de entrada que aceptan (ej: pulsador, control ocular, pantalla táctil)
sistema_entrada = bd.Table('sistema_entrada',
    bd.Column('sistema_id', bd.Integer, bd.ForeignKey('saac_sistema.id', ondelete='CASCADE'), primary_key=True),
    bd.Column('entrada_id', bd.Integer, bd.ForeignKey('tipo_entrada.id', ondelete='CASCADE'), primary_key=True))

#Relaciona sistemas SAAC con los idiomas en los que están disponibles
sistema_idioma = bd.Table('sistema_idioma',
    bd.Column('sistema_id', bd.Integer, bd.ForeignKey('saac_sistema.id', ondelete='CASCADE'), primary_key=True),
    bd.Column('idioma_id', bd.Integer, bd.ForeignKey('idioma.id', ondelete='CASCADE'), primary_key=True))

#Relaciona sistemas SAAC con las plataformas en las que funcionan (ej: iOS, Android, Windows)
sistema_plataforma = bd.Table('sistema_plataforma',
    bd.Column('sistema_id', bd.Integer, bd.ForeignKey('saac_sistema.id', ondelete='CASCADE'), primary_key=True),
    bd.Column('plataforma_id', bd.Integer, bd.ForeignKey('plataforma.id', ondelete='CASCADE'), primary_key=True))

#Relaciona pacientes con los tipos de entrada que pueden usar
paciente_entrada = bd.Table('paciente_entrada',
    bd.Column('paciente_id', bd.Integer, bd.ForeignKey('paciente.id', ondelete='CASCADE'), primary_key=True),
    bd.Column('entrada_id', bd.Integer, bd.ForeignKey('tipo_entrada.id', ondelete='CASCADE'), primary_key=True))

#Relaciona sistemas SAAC con sus métodos de comunicación compatibles (ej: pictogramas, alfabeto, lectura/escritura)
sistema_metodo = bd.Table('sistema_metodo',
    bd.Column('sistema_id', bd.Integer, bd.ForeignKey('saac_sistema.id', ondelete='CASCADE'), primary_key=True),
    bd.Column('metodo_id', bd.Integer, bd.ForeignKey('metodo_comunicacion.id', ondelete='CASCADE'), primary_key=True))

#TABLAS MAESTRAS (valores posibles para las opciones del cuestionario)
#Métodos de interacción con el dispositivo (ej: pulsador, pantalla táctil, control ocular, voz)
class TipoEntrada(bd.Model):
    __tablename__ = 'tipo_entrada'
    id = bd.Column(bd.Integer, primary_key=True)
    nombre = bd.Column(bd.Text, unique=True, nullable=False)

#Idiomas disponibles (ej: español, gallego, catalan)
class Idioma(bd.Model):
    __tablename__ = 'idioma'
    id = bd.Column(bd.Integer, primary_key=True)
    nombre = bd.Column(bd.Text, unique=True, nullable=False)

#Plataformas (ej: iOs, Android, Windows, Panel físico/Papel)
class Plataforma(bd.Model):
    __tablename__ = 'plataforma'
    id = bd.Column(bd.Integer, primary_key=True)
    nombre = bd.Column(bd.Text, unique=True, nullable=False)

#Entornos donde puede utilizarse (ej: Domicilio, exterior, mixto)
class EntornoUso(bd.Model):
    __tablename__ = 'entorno_uso'
    id = bd.Column(bd.Integer, primary_key=True)
    nombre = bd.Column(bd.Text, unique=True, nullable=False)

#Métodos de representación (ej: Alfabeto, pictogramas)
class MetodoComunicacion(bd.Model):
    __tablename__ = 'metodo_comunicacion'
    id = bd.Column(bd.Integer, primary_key=True)
    nombre = bd.Column(bd.String, unique=True)

#TABLAS DE DATOS PRINCIPALES
#Representa cada SAAC disponible
class SaacSistema(bd.Model):
    __tablename__ = 'saac_sistema'
    id = bd.Column(bd.Integer, primary_key=True)
    nombre = bd.Column(bd.Text, nullable=False)
    descripcion = bd.Column(bd.Text)
    requiere_interlocutor = bd.Column(bd.Boolean) #Necesita interlocutor para ser usado
    fatiga_fisica = bd.Column(bd.SmallInteger) #Nivel de esfuerzo físico que exige su uso
    portable = bd.Column(bd.Boolean) #Es transportable con facilidad
    admite_anclaje = bd.Column(bd.Boolean) #Permite anclarlo a silla de ruedas o similares
    enlace_info = bd.Column(bd.Text) #Link con más info del producto
    categoria = bd.Column(bd.String) #Categoría a la que pertenece (Sistema, hardware periférico o banco de voz)
    requiere_hardware_extra = bd.Column(bd.Boolean, default=False) #Requiere periférico para funcionar (ej: eye tracker, pulsador)

    #RELACIONES
    #Con requisitos funcionales uno a uno
    requisitos = bd.relationship('SistemaRequisitoFuncional', backref='sistema', uselist=False, cascade="all, delete")
    
    #Relaciones muchos a muchos mediante las tablas definidas antes
    entornos = bd.relationship('EntornoUso', secondary=sistema_entorno, backref='sistemas')
    entradas = bd.relationship('TipoEntrada', secondary=sistema_entrada, backref='sistemas')
    idiomas = bd.relationship('Idioma', secondary=sistema_idioma, backref='sistemas')
    plataformas = bd.relationship('Plataforma', secondary=sistema_plataforma, backref='sistemas')
    metodos = bd.relationship('MetodoComunicacion', secondary='sistema_metodo', backref='sistemas')
    
#Umbrales mínimos que el paciente debe cumplir para que se le recomiende cierto SAAC
class SistemaRequisitoFuncional(bd.Model):
    __tablename__ = 'sistema_requisito_funcional'
    sistema_id = bd.Column(bd.Integer, bd.ForeignKey('saac_sistema.id', ondelete='CASCADE'), primary_key=True)
    nivel_visual_min = bd.Column(bd.SmallInteger) #Nivel visual mínimo requerido
    nivel_auditivo_min = bd.Column(bd.SmallInteger) #Nivel auditivo mínimo requerido
    nivel_tecnologico_min = bd.Column(bd.SmallInteger) #Nivel tecnológico mínimo requerido 
    nivel_habla_min = bd.Column(bd.SmallInteger) #Nivel de habla mínimo requerido

#Perfil clínico del paciente
class Paciente(bd.Model):
    __tablename__ = 'paciente'
    id = bd.Column(bd.Integer, primary_key=True)
    nombre = bd.Column(bd.Text)
    vision = bd.Column(bd.SmallInteger)
    audicion = bd.Column(bd.SmallInteger)
    tecnologia = bd.Column(bd.SmallInteger)
    resistencia = bd.Column(bd.SmallInteger)
    necesita_independencia = bd.Column(bd.Boolean)
    usa_silla = bd.Column(bd.Boolean)
    
    #Foreign keys
    entorno_id = bd.Column(bd.Integer, bd.ForeignKey('entorno_uso.id'))
    idioma_id = bd.Column(bd.Integer, bd.ForeignKey('idioma.id'), nullable=False)
    plataforma_preferida_id = bd.Column(bd.Integer, bd.ForeignKey('plataforma.id'))

    #Relación muchos a muchos con entradas
    entradas = bd.relationship('TipoEntrada', secondary=paciente_entrada, backref='pacientes')

#Tabla para guardar resultados de tests. Almacena tanto las respuestas al cuestionario como la recomendación hecha.
# Si corresponde también y el feedback posterior del usuario.
# Sirve como base para análisis de uso.

class HistorialRecomendacion(bd.Model):
    __tablename__ = 'historial_recomendacion'
    id = bd.Column(bd.Integer, primary_key=True)
    fecha = bd.Column(bd.DateTime, default=datetime.utcnow) #Fecha y hora de la recomendación
    nombre_paciente = bd.Column(bd.String(100)) #ID anónimo generado para el paciente
    input_usuario = bd.Column(bd.JSON) #JSON con perfil de usuario como se introdujo al cuestionario (incluye niveles clínicos, idioma, plataforma...)
    sistemas_recomendados = bd.Column(bd.Text) #Texto con nombres de los sistemas recomendados y accesorios asociados
    feedback = bd.Column(bd.JSON, nullable=True) #JSON con las valoraciones del usuario
    es_real = bd.Column(bd.Boolean, default=False) #Distinción entre registros reales y feedback

    def __repr__(self):
        return f'<Recomendacion {self.nombre_paciente} - {self.fecha}>'