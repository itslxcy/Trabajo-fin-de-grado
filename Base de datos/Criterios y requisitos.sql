
DROP TABLE IF EXISTS paciente_entrada CASCADE;
DROP TABLE IF EXISTS sistema_entrada CASCADE;
DROP TABLE IF EXISTS sistema_idioma CASCADE;
DROP TABLE IF EXISTS paciente CASCADE;
DROP TABLE IF EXISTS saac_sistema CASCADE;
DROP TABLE IF EXISTS tipo_entrada CASCADE;
DROP TABLE IF EXISTS idioma CASCADE;

-- TABLAS CATÁLOGO

CREATE TABLE tipo_entrada (
    id SERIAL PRIMARY KEY,
    nombre TEXT UNIQUE NOT NULL
);

INSERT INTO tipo_entrada (nombre) VALUES
('manos'),
('ojos'),
('cabeza'),
('voz'),
('pulsador'),
('cerebro');

-------------------------------------------------------

CREATE TABLE idioma (
    id SERIAL PRIMARY KEY,
    nombre TEXT UNIQUE NOT NULL
);

INSERT INTO idioma (nombre) VALUES
('español'),
('inglés');

-- TABLA SISTEMAS SAAC

CREATE TABLE saac_sistema (
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL,
    descripcion TEXT,

    coste_min NUMERIC,
    coste_max NUMERIC,
    requiere_financiacion BOOLEAN DEFAULT FALSE,

    nivel_visual SMALLINT,
    nivel_auditivo SMALLINT,
    nivel_cognitivo SMALLINT,
    nivel_tecnologico SMALLINT,

    requiere_interlocutor BOOLEAN,
    tiempo_entrenamiento SMALLINT,
    fatiga_fisica SMALLINT,
    velocidad SMALLINT,
    robustez SMALLINT,
    escalabilidad SMALLINT,

    portable BOOLEAN,
    admite_anclaje BOOLEAN
);

-- RELACIONES SISTEMA

CREATE TABLE sistema_entrada (
    sistema_id INT REFERENCES saac_sistema(id) ON DELETE CASCADE,
    entrada_id INT REFERENCES tipo_entrada(id) ON DELETE CASCADE,
    PRIMARY KEY (sistema_id, entrada_id)
);

-------------------------------------------------------

CREATE TABLE sistema_idioma (
    sistema_id INT REFERENCES saac_sistema(id) ON DELETE CASCADE,
    idioma_id INT REFERENCES idioma(id) ON DELETE CASCADE,
    PRIMARY KEY (sistema_id, idioma_id)
);

-- TABLA PACIENTE

CREATE TABLE paciente (
    id SERIAL PRIMARY KEY,
    nombre TEXT,

    presupuesto NUMERIC,
    vision SMALLINT,
    audicion SMALLINT,
    cognicion SMALLINT,
    tecnologia SMALLINT,
    resistencia SMALLINT,

    necesita_independencia BOOLEAN,
    usa_silla BOOLEAN,
    entorno SMALLINT,
    tiene_financiacion BOOLEAN DEFAULT FALSE
);

-------------------------------------------------------

CREATE TABLE paciente_entrada (
    paciente_id INT REFERENCES paciente(id) ON DELETE CASCADE,
    entrada_id INT REFERENCES tipo_entrada(id) ON DELETE CASCADE,
    PRIMARY KEY (paciente_id, entrada_id)
);

-- ÍNDICES

CREATE INDEX idx_sistema_coste_min ON saac_sistema(coste_min);
CREATE INDEX idx_sistema_cognitivo ON saac_sistema(nivel_cognitivo);
CREATE INDEX idx_sistema_visual ON saac_sistema(nivel_visual);
CREATE INDEX idx_sistema_velocidad ON saac_sistema(velocidad);

-------------------------------------------------------
-- DATOS SISTEMAS
-------------------------------------------------------

INSERT INTO saac_sistema
(nombre, descripcion, coste_min, coste_max, requiere_financiacion,
 nivel_visual, nivel_auditivo, nivel_cognitivo, nivel_tecnologico,
 requiere_interlocutor, tiempo_entrenamiento, fatiga_fisica,
 velocidad, robustez, escalabilidad, portable, admite_anclaje)

VALUES
('Panel pictogramas','Tablero símbolos',20,80,false,3,0,1,0,true,1,1,1,3,2,true,true),
('Panel alfabético','Tablero letras',20,60,false,3,0,2,0,true,2,2,1,3,2,true,true),
('SpeakBook','Cuaderno comunicación',10,50,false,3,0,1,0,true,1,1,1,3,2,true,true),
('Gafas láser','Puntero montado',80,150,false,3,0,1,0,false,1,1,2,3,0,true,true),
('MegaBEE','Comunicador mirada',600,900,false,3,0,2,2,true,2,1,2,2,1,true,true),
('Look to Speak','App mirada',0,0,false,3,1,2,2,false,2,1,2,2,2,true,true),
('Grid 3','Software comunicación',500,900,false,2,3,2,3,false,2,1,3,2,3,true,true),
('TTS móvil','Texto a voz',0,50,false,1,3,1,1,false,1,1,2,3,2,true,false),
('Eye tracker','Seguimiento ocular',1500,3000,true,3,1,2,3,false,3,1,3,2,3,false,true),
('Proloquo2Go','App pictográfica avanzada',800,1200,false,2,3,2,2,false,2,1,3,3,3,true,true),
('TD Snap','Comunicador profesional',800,1400,false,2,3,2,3,false,2,1,3,3,3,true,true),
('LAMP Words for Life','Sistema lingüístico motor',900,1500,false,2,3,3,2,false,3,2,3,3,3,true,true),
('PECS','Intercambio de imágenes',50,200,false,2,1,1,1,true,2,1,1,3,2,true,false),
('Tablero ETRAN','Panel transparente',40,150,false,3,1,1,1,true,1,1,1,3,1,true,true),
('Switch scanning','Barrido con pulsador',300,800,false,1,2,2,2,false,2,1,1,3,3,true,true),
('BCI comunicador','Interfaz cerebral',4000,10000,true,1,2,3,4,false,4,1,1,1,4,false,true);

-------------------------------------------------------
-- ENTRADAS CORRECTAS
-------------------------------------------------------

INSERT INTO sistema_entrada
SELECT id,1 FROM saac_sistema WHERE nombre IN
('TTS móvil','Proloquo2Go','LAMP Words for Life','PECS');

INSERT INTO sistema_entrada
SELECT id,2 FROM saac_sistema WHERE nombre IN
('MegaBEE','Look to Speak','Eye tracker','Tablero ETRAN');

INSERT INTO sistema_entrada
SELECT id,3 FROM saac_sistema WHERE nombre='Gafas láser';

INSERT INTO sistema_entrada
SELECT id,5 FROM saac_sistema WHERE nombre IN
('Switch scanning','Grid 3');

INSERT INTO sistema_entrada
SELECT id,6 FROM saac_sistema WHERE nombre='BCI comunicador';

-------------------------------------------------------
-- IDIOMAS
-------------------------------------------------------

INSERT INTO sistema_idioma
SELECT id,1 FROM saac_sistema;

INSERT INTO sistema_idioma
SELECT id,2 FROM saac_sistema
WHERE nombre IN ('Grid 3','TD Snap','Proloquo2Go','Eye tracker','Look to Speak');