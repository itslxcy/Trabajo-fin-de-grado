-- 1. LIMPIEZA TOTAL DE TABLAS
DROP TABLE IF EXISTS sistema_plataforma CASCADE;
DROP TABLE IF EXISTS sistema_idioma CASCADE;
DROP TABLE IF EXISTS sistema_entrada CASCADE;
DROP TABLE IF EXISTS sistema_entorno CASCADE;
DROP TABLE IF EXISTS sistema_requisito_funcional CASCADE;
DROP TABLE IF EXISTS saac_sistema CASCADE;
DROP TABLE IF EXISTS tipo_entrada CASCADE;
DROP TABLE IF EXISTS idioma CASCADE;
DROP TABLE IF EXISTS plataforma CASCADE;
DROP TABLE IF EXISTS entorno_uso CASCADE;

-- 2. TABLAS MAESTRAS
CREATE TABLE tipo_entrada (
    id SERIAL PRIMARY KEY,
    nombre TEXT UNIQUE NOT NULL
);
INSERT INTO tipo_entrada (nombre) VALUES
('manos'), ('ojos'), ('cabeza'), ('voz'), ('pulsador');

CREATE TABLE idioma (
    id SERIAL PRIMARY KEY,
    nombre TEXT UNIQUE NOT NULL
);
INSERT INTO idioma (nombre) VALUES
('español'), ('gallego'), ('catalán'), ('euskera');

CREATE TABLE plataforma (
    id SERIAL PRIMARY KEY,
    nombre TEXT UNIQUE NOT NULL
);
INSERT INTO plataforma (nombre) VALUES 
('Windows'), ('iOS'), ('Android'), ('Hardware Propio'), ('Web');

CREATE TABLE entorno_uso (
    id SERIAL PRIMARY KEY,
    nombre TEXT UNIQUE NOT NULL
);
INSERT INTO entorno_uso (nombre) VALUES 
('Interior/Cama'), ('Interior/Silla'), ('Exterior/Luz Solar'), ('Exterior/Movimiento');

-- 3. TABLA DE SISTEMAS SAAC
CREATE TABLE saac_sistema (
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL,
    descripcion TEXT,
    coste_min NUMERIC,
    requiere_interlocutor BOOLEAN,
    fatiga_fisica SMALLINT,
    portable BOOLEAN, 
    admite_anclaje BOOLEAN,
    enlace_info TEXT
);

-- 4. TABLA DE REQUISITOS FUNCIONALES
CREATE TABLE sistema_requisito_funcional (
    sistema_id INT PRIMARY KEY REFERENCES saac_sistema(id) ON DELETE CASCADE,
    nivel_visual_min SMALLINT DEFAULT 0,
    nivel_auditivo_min SMALLINT DEFAULT 0,
    nivel_cognitivo_min SMALLINT DEFAULT 0,
    nivel_tecnologico_min SMALLINT DEFAULT 0,
    nivel_habla_min SMALLINT DEFAULT 0
);

-- 5. TABLAS DE RELACIÓN
CREATE TABLE sistema_entorno (
    sistema_id INT REFERENCES saac_sistema(id) ON DELETE CASCADE,
    entorno_id INT REFERENCES entorno_uso(id) ON DELETE CASCADE,
    PRIMARY KEY (sistema_id, entorno_id)
);

CREATE TABLE sistema_entrada (
    sistema_id INT REFERENCES saac_sistema(id) ON DELETE CASCADE,
    entrada_id INT REFERENCES tipo_entrada(id) ON DELETE CASCADE,
    PRIMARY KEY (sistema_id, entrada_id)
);

CREATE TABLE sistema_idioma (
    sistema_id INT REFERENCES saac_sistema(id) ON DELETE CASCADE,
    idioma_id INT REFERENCES idioma(id) ON DELETE CASCADE,
    PRIMARY KEY (sistema_id, idioma_id)
);

CREATE TABLE sistema_plataforma (
    sistema_id INT REFERENCES saac_sistema(id) ON DELETE CASCADE,
    plataforma_id INT REFERENCES plataforma(id) ON DELETE CASCADE,
    PRIMARY KEY (sistema_id, plataforma_id)
);

-- 6. CARGA DE SISTEMAS
INSERT INTO saac_sistema 
(nombre, descripcion, coste_min, requiere_interlocutor, fatiga_fisica, portable, admite_anclaje, enlace_info)
VALUES
-- SISTEMAS DE BAJA TECNOLOGÍA
('Panel pictogramas','Tablero físico que utiliza símbolos pictográficos (ARASAAC) para representar conceptos, acciones o necesidades básicas.',0,true,3,true,true, 'https://arasaac.org/'),
('Panel alfabético','Tablero de comunicación directa mediante el deletreo, diseñado para usuarios con lectoescritura preservada.',0,true,3,true,true, 'https://downloads.tobiidynavox.com/Conditions/ALS/Communication_Board/TD_CommunicationBoard_ALS_es-ES.pdf'),
('SpeakBook','Cuaderno de comunicación diseñado para la selección mediante la mirada o puntero.',0,true,2,true,true, 'https://acecentre.org.uk/resources/speakbook'),
('Tablero ETRAN','Panel transparente que permite la comunicación mediante la dirección de la mirada.',90,true,1,true,true, 'https://qinera.com/es/tienda/comunicadores-sencillos/comunicador-tipo-etran'),
('MegaBEE','Dispositivo de baja tecnología con pantalla que permite escribir mensajes con la mirada.',770,true,1,true,true, 'https://assistive.co.nz/product/megabee/'),
('QuickTalker 23','Comunicador portátil con 23 casillas para mensajes grabados, ideal para comunicación por presión directa.',250,false,3,true,false, 'https://qinera.com/es/tienda/comunicadores-sencillos/quick-talker-23'),

-- SOFTWARE Y APPS
('Look to Speak','Uso de mirada a través de cámara frontal para selección de frases preestablecidas.',0,false,1,true,true, 'https://play.google.com/store/apps/details?id=com.androidexperiments.looktospeak&hl=es'),
('Tallk','Seguimiento ocular a través de la cámara de la tablet (Samsung).',0,false,1,true,true, 'https://play.google.com/store/apps/details?id=com.irisbond.tallk&hl=es'),
('Grid 3','Software integral para comunicación, control del entorno y acceso a Windows.',300,false,1,true,true, 'https://qinera.com/es/tienda/software-para-la-comunicacion/grid-3'),
('Verbo','Software de comunicación dinámico con salida de voz y creación de tableros.',40,false,1,true,true, 'https://www.bjadaptaciones.com/software/verbo'),
('Proloquo2Go','Comunicación simbólica para iOS basada en lenguaje natural.',300,false,2,true,true, 'https://www.assistiveware.com/es/productos/proloquo2go'),
('TD Snap','Software centrado en símbolos y alfabetización navegación rápida.',60,false,1,true,true, 'https://es.tobiidynavox.com/pages/td-snap'),
('Communicator 5','Software de comunicación eficiente para usuarios de texto y símbolos.',600,false,1,true,true, 'https://qinera.com/es/tienda/software-para-la-comunicacion/communicator-5'),
('Boardmaker 7','Plataforma estándar para crear materiales de comunicación basados en símbolos.',200,true,2,true,true, 'https://qinera.com/es/tienda/software-para-la-comunicacion/boardmaker-7'),
('Look to learn','Software de entrenamiento para el aprendizaje del control ocular.',520,true,1,true,true, 'https://qinera.com/es/tienda/software-para-la-comunicacion/look-to-learn-1-licencia-electronica'),
('TouchChat','Herramienta con símbolos, texto y predicción de palabras.',150,false,2,true,true, 'https://touchchatapp.com/'),
('LetMeTalk','App de comunicación mediante pictogramas gratuita.',0,false,2,true,false, 'https://www.letmetalk.info/es'),

-- ACCESO POR VOZ Y PACKS
('Asistente de voz AAC','Conversión de voz a texto.',0,false,1,true,false, 'https://play.google.com/store/apps/details?id=nl.asoft.speechassistant&hl=es'),
('Speak4Me','App para reproducir frases rápidas guardadas.',0,false,1,true,false, 'https://speak4me.io/'),
('ComuniQa (TD Snap)','Pack tablet + seguimiento ocular + software TD Snap.',4000,false,1,true,true, 'https://qinera.com/es/tienda/comunicadores-de-mirada/comuniqa-eye-con-td-snap'),
('ComuniQa (Grid 3)','Pack tablet + seguimiento ocular + software Grid 3.',4000,false,1,true,true, 'https://qinera.com/es/tienda/comunicadores-de-mirada/comuniqa-eye-con-grid-3'),
('TD Pilot','Comunicador ocular de alta gama integrado para iPad.',7000,false,1,true,true, 'https://qinera.com/es/tienda/comunicadores-de-mirada/TD-Pilot'),

-- PERIFÉRICOS
('Eye tracker','Lector ocular para control de dispositivos por mirada.',260,false,1,false,true, 'https://qinera.com/es/tienda/lectores-oculares/tobii-pceye-5'),
('Puntero Láser','Señalización directa para tableros físicos.',99,true,3,true,false, NULL),
('Gafas con Puntero Láser', 'Puntero láser adaptado para control cefálico.', 120,true,2,true,false, 'https://www.elaandalucia.es/gafas-puntero-laser-todas-las-unidades-hospitalarias-ela-andalucia/'),
('Soporte de anclaje articulado', 'Brazo mecánico para fijación de dispositivos a silla.', 250,false,0,false,true, 'https://qinera.com/es/tienda/comunicacion-aumentativa/soportes-y-brazos-caa'),
('Conmutador por soplido (Pufo)', 'Sensor de alta sensibilidad que detecta soplidos suaves para activar el comunicador.', 350, false, 0, true, true, 'https://qinera.com/es/tienda/acceso-a-dispositivos-y-conmutadores/quha-pufo-con-kit-de-montaje-de-cabeza'),
('Conmutador de pedal', 'Pulsador robusto diseñado para ser activado con el pie.', 115, false, 2, true, false, 'https://qinera.com/es/tienda/ratones-y-pulsadores/conmutador-de-pedal'),
('Conmutador Spec Amarillo', 'Pulsador de pequeño tamaño y fácil activación por presión física mínima.', 75, false, 2, true, true, 'http://qinera.com/es/tienda/conmutadores/conmutador-spec-amarillo'),
('BJOY Chin Plus', 'Conmutador de barbilla de alta precisión tipo joystick para control de cursor.', 550, false, 1, true, true, 'https://qinera.com/es/tienda/ratones-y-pulsadores/bjoy-chin-plus'),

-- BANCOS DE VOZ
('ModelTalker Gen3', 'Síntesis de voz personalizada.', 0,false,2,true,false, 'https://modeltalker.org/'),
('MyOwnVoice (Acapela)', 'Voz digital idéntica mediante Deep Learning.', 0,false,1,true,false, 'https://mov.acapela-group.com/es/home-es/'),
('VocaliD', 'Hibridación de voz personalizada.', 0,false,1,true,false, 'https://vocalid.ai/');

-- 7. REQUISITOS FUNCIONALES
INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_cognitivo_min, nivel_tecnologico_min, nivel_habla_min)
SELECT id, 3, 1, 2, 0, 0 FROM saac_sistema 
WHERE nombre IN ('Eye tracker', 'Tallk', 'Look to Speak', 'MegaBEE', 'Look to learn', 'Panel pictogramas', 'Panel alfabético', 'SpeakBook', 'Tablero ETRAN', 'Puntero Láser', 'Gafas con Puntero Láser');

INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_cognitivo_min, nivel_tecnologico_min, nivel_habla_min)
SELECT id, 2, 2, 3, 3, 0 FROM saac_sistema 
WHERE nombre IN ('Grid 3', 'Verbo', 'TD Snap', 'ComuniQa (TD Snap)', 'ComuniQa (Grid 3)', 'Communicator 5', 'TD Pilot');

INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_cognitivo_min, nivel_tecnologico_min, nivel_habla_min)
SELECT id, 1, 1, 2, 2, 0 FROM saac_sistema 
WHERE nombre IN ('Boardmaker 7', 'QuickTalker 23', 'Conmutador por soplido (Pufo)', 'Conmutador de pedal', 'Conmutador Spec Amarillo', 'BJOY Chin Plus');

INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_cognitivo_min, nivel_tecnologico_min, nivel_habla_min)
SELECT id, 0, 1, 2, 0, 3 FROM saac_sistema 
WHERE nombre IN ('ModelTalker Gen3', 'MyOwnVoice (Acapela)', 'VocaliD');

INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_cognitivo_min, nivel_tecnologico_min, nivel_habla_min)
SELECT id, 0, 0, 0, 0, 0 FROM saac_sistema 
WHERE nombre = 'Soporte de anclaje articulado' 
   OR id NOT IN (SELECT sistema_id FROM sistema_requisito_funcional);

-- 8. RELACIONES DE ENTRADA
INSERT INTO sistema_entrada (sistema_id, entrada_id)
SELECT id, (SELECT id FROM tipo_entrada WHERE nombre = 'manos') FROM saac_sistema 
WHERE nombre IN ('Panel pictogramas', 'Panel alfabético', 'SpeakBook', 'Puntero Láser', 'Asistente de voz AAC', 'Proloquo2Go', 'Grid 3', 'Verbo', 'Boardmaker 7', 'QuickTalker 23', 'LetMeTalk', 'TD Snap', 'Conmutador Spec Amarillo');

INSERT INTO sistema_entrada (sistema_id, entrada_id)
SELECT id, (SELECT id FROM tipo_entrada WHERE nombre = 'ojos') FROM saac_sistema 
WHERE nombre IN ('MegaBEE', 'Look to Speak', 'Eye tracker', 'Tablero ETRAN', 'Tallk', 'Look to learn', 'Grid 3', 'ComuniQa (TD Snap)', 'ComuniQa (Grid 3)', 'TD Pilot', 'Communicator 5');

INSERT INTO sistema_entrada (sistema_id, entrada_id)
SELECT id, (SELECT id FROM tipo_entrada WHERE nombre = 'pulsador') FROM saac_sistema 
WHERE nombre IN ('QuickTalker 23', 'Conmutador de pedal', 'Conmutador por soplido (Pufo)', 'BJOY Chin Plus', 'Grid 3', 'Communicator 5');

INSERT INTO sistema_entrada (sistema_id, entrada_id)
SELECT id, (SELECT id FROM tipo_entrada WHERE nombre = 'cabeza') FROM saac_sistema 
WHERE nombre IN ('Gafas con Puntero Láser', 'SpeakBook', 'BJOY Chin Plus');

-- 9. RELACIONES DE IDIOMA
INSERT INTO sistema_idioma (sistema_id, idioma_id)
SELECT s.id, (SELECT id FROM idioma WHERE nombre = 'español') FROM saac_sistema s;

INSERT INTO sistema_idioma (sistema_id, idioma_id)
SELECT s.id, i.id FROM saac_sistema s, idioma i 
WHERE s.nombre IN ('Grid 3', 'Verbo', 'TD Snap', 'Communicator 5', 'TD Pilot') AND i.nombre IN ('catalán', 'gallego', 'euskera');

-- 10. RELACIONES DE PLATAFORMA
INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, (SELECT id FROM plataforma WHERE nombre = 'Hardware Propio') FROM saac_sistema 
WHERE nombre IN ('Panel pictogramas', 'Panel alfabético', 'SpeakBook', 'Puntero Láser', 'MegaBEE', 'Tablero ETRAN', 'QuickTalker 23', 'ComuniQa (TD Snap)', 'ComuniQa (Grid 3)', 'Soporte de anclaje articulado', 'Conmutador de pedal', 'Conmutador Spec Amarillo', 'BJOY Chin Plus');

INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, (SELECT id FROM plataforma WHERE nombre = 'Windows') FROM saac_sistema 
WHERE nombre IN ('Grid 3', 'Eye tracker', 'Verbo', 'Look to learn', 'TD Snap', 'Communicator 5', 'Boardmaker 7', 'BJOY Chin Plus');

INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, (SELECT id FROM plataforma WHERE nombre = 'iOS') FROM saac_sistema 
WHERE nombre IN ('Proloquo2Go', 'TD Snap', 'TD Pilot', 'Boardmaker 7', 'LetMeTalk');

INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, (SELECT id FROM plataforma WHERE nombre = 'Android') FROM saac_sistema 
WHERE nombre IN ('Look to Speak', 'Tallk', 'LetMeTalk');