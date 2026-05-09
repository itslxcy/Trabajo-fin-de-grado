from datetime import datetime
from extension import bd

#Tablas de relación muchos a muchos
sistema_entorno = bd.Table('sistema_entorno',
    bd.Column('sistema_id', bd.Integer, bd.ForeignKey('saac_sistema.id', ondelete='CASCADE'), primary_key=True),
    bd.Column('entorno_id', bd.Integer, bd.ForeignKey('entorno_uso.id', ondelete='CASCADE'), primary_key=True)
)

sistema_entrada = bd.Table('sistema_entrada',
    bd.Column('sistema_id', bd.Integer, bd.ForeignKey('saac_sistema.id', ondelete='CASCADE'), primary_key=True),
    bd.Column('entrada_id', bd.Integer, bd.ForeignKey('tipo_entrada.id', ondelete='CASCADE'), primary_key=True)
)

sistema_idioma = bd.Table('sistema_idioma',
    bd.Column('sistema_id', bd.Integer, bd.ForeignKey('saac_sistema.id', ondelete='CASCADE'), primary_key=True),
    bd.Column('idioma_id', bd.Integer, bd.ForeignKey('idioma.id', ondelete='CASCADE'), primary_key=True)
)

sistema_plataforma = bd.Table('sistema_plataforma',
    bd.Column('sistema_id', bd.Integer, bd.ForeignKey('saac_sistema.id', ondelete='CASCADE'), primary_key=True),
    bd.Column('plataforma_id', bd.Integer, bd.ForeignKey('plataforma.id', ondelete='CASCADE'), primary_key=True)
)

paciente_entrada = bd.Table('paciente_entrada',
    bd.Column('paciente_id', bd.Integer, bd.ForeignKey('paciente.id', ondelete='CASCADE'), primary_key=True),
    bd.Column('entrada_id', bd.Integer, bd.ForeignKey('tipo_entrada.id', ondelete='CASCADE'), primary_key=True)
)

sistema_metodo = bd.Table('sistema_metodo',
    bd.Column('sistema_id', bd.Integer, bd.ForeignKey('saac_sistema.id'), primary_key=True),
    bd.Column('metodo_id', bd.Integer, bd.ForeignKey('metodo_comunicacion.id'), primary_key=True)
)

#Tablas maestras
class TipoEntrada(bd.Model):
    __tablename__ = 'tipo_entrada'
    id = bd.Column(bd.Integer, primary_key=True)
    nombre = bd.Column(bd.Text, unique=True, nullable=False)

class Idioma(bd.Model):
    __tablename__ = 'idioma'
    id = bd.Column(bd.Integer, primary_key=True)
    nombre = bd.Column(bd.Text, unique=True, nullable=False)

class Plataforma(bd.Model):
    __tablename__ = 'plataforma'
    id = bd.Column(bd.Integer, primary_key=True)
    nombre = bd.Column(bd.Text, unique=True, nullable=False)

class EntornoUso(bd.Model):
    __tablename__ = 'entorno_uso'
    id = bd.Column(bd.Integer, primary_key=True)
    nombre = bd.Column(bd.Text, unique=True, nullable=False)

class MetodoComunicacion(bd.Model):
    __tablename__ = 'metodo_comunicacion'
    id = bd.Column(bd.Integer, primary_key=True)
    nombre = bd.Column(bd.String, unique=True)

#Tablas de datos
class SaacSistema(bd.Model):
    __tablename__ = 'saac_sistema'
    id = bd.Column(bd.Integer, primary_key=True)
    nombre = bd.Column(bd.Text, nullable=False)
    descripcion = bd.Column(bd.Text)
    requiere_interlocutor = bd.Column(bd.Boolean)
    fatiga_fisica = bd.Column(bd.SmallInteger)
    portable = bd.Column(bd.Boolean)
    admite_anclaje = bd.Column(bd.Boolean)
    enlace_info = bd.Column(bd.Text)
    categoria = bd.Column(bd.String)
    requiere_hardware_extra = bd.Column(bd.Boolean, default=False)

    #Relación con requisitos funcionales uno a uno
    requisitos = bd.relationship('SistemaRequisitoFuncional', backref='sistema', uselist=False, cascade="all, delete")
    
    #Relaciones muchos a muchos
    entornos = bd.relationship('EntornoUso', secondary=sistema_entorno, backref='sistemas')
    entradas = bd.relationship('TipoEntrada', secondary=sistema_entrada, backref='sistemas')
    idiomas = bd.relationship('Idioma', secondary=sistema_idioma, backref='sistemas')
    plataformas = bd.relationship('Plataforma', secondary=sistema_plataforma, backref='sistemas')
    metodos = bd.relationship('MetodoComunicacion', secondary='sistema_metodo', backref='sistemas')
    

class SistemaRequisitoFuncional(bd.Model):
    __tablename__ = 'sistema_requisito_funcional'
    sistema_id = bd.Column(bd.Integer, bd.ForeignKey('saac_sistema.id', ondelete='CASCADE'), primary_key=True)
    nivel_visual_min = bd.Column(bd.SmallInteger, default=0)
    nivel_auditivo_min = bd.Column(bd.SmallInteger, default=0)
    nivel_tecnologico_min = bd.Column(bd.SmallInteger, default=0)
    nivel_habla_min = bd.Column(bd.SmallInteger, default=0)

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
    tiene_financiacion = bd.Column(bd.Boolean, default=False)
    
    #Foreign keys
    entorno_id = bd.Column(bd.Integer, bd.ForeignKey('entorno_uso.id'))
    idioma_id = bd.Column(bd.Integer, bd.ForeignKey('idioma.id'), nullable=False)
    plataforma_preferida_id = bd.Column(bd.Integer, bd.ForeignKey('plataforma.id'))

    #Relación muchos a muchos con entradas
    entradas = bd.relationship('TipoEntrada', secondary=paciente_entrada, backref='pacientes')

#Tabla para guardar resultados de tests
class HistorialRecomendacion(bd.Model):
    __tablename__ = 'historial_recomendacion'
    id = bd.Column(bd.Integer, primary_key=True)
    fecha = bd.Column(bd.DateTime, default=datetime.utcnow)
    nombre_paciente = bd.Column(bd.String(100))
    input_usuario = bd.Column(bd.JSON) 
    sistemas_recomendados = bd.Column(bd.Text)
    feedback = bd.Column(bd.JSON, nullable=True)

    def __repr__(self):
        return f'<Recomendacion {self.nombre_paciente} - {self.fecha}>'