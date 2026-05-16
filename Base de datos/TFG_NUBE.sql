-- 1. LIMPIEZA TOTAL
DROP TABLE IF EXISTS historial_recomendacion CASCADE;
DROP TABLE IF EXISTS sistema_metodo CASCADE;
DROP TABLE IF EXISTS sistema_plataforma CASCADE;
DROP TABLE IF EXISTS sistema_idioma CASCADE;
DROP TABLE IF EXISTS sistema_entrada CASCADE;
DROP TABLE IF EXISTS sistema_entorno CASCADE;
DROP TABLE IF EXISTS sistema_requisito_funcional CASCADE;
DROP TABLE IF EXISTS saac_sistema CASCADE;
DROP TABLE IF EXISTS metodo_comunicacion CASCADE;
DROP TABLE IF EXISTS tipo_entrada CASCADE;
DROP TABLE IF EXISTS idioma CASCADE;
DROP TABLE IF EXISTS plataforma CASCADE;
DROP TABLE IF EXISTS entorno_uso CASCADE;
DROP TABLE IF EXISTS sistema_dependencia CASCADE;

-- 2. TABLAS MAESTRAS
CREATE TABLE tipo_entrada (id SERIAL PRIMARY KEY, nombre TEXT UNIQUE NOT NULL);
INSERT INTO tipo_entrada (nombre) VALUES ('manos'), ('ojos'), ('cabeza'), ('voz'), ('pulsador');

CREATE TABLE idioma (id SERIAL PRIMARY KEY, nombre TEXT UNIQUE NOT NULL);
INSERT INTO idioma (nombre) VALUES ('español'), ('gallego'), ('catalán'), ('euskera');

CREATE TABLE plataforma (id SERIAL PRIMARY KEY, nombre TEXT UNIQUE NOT NULL);
INSERT INTO plataforma (nombre) VALUES ('Windows'), ('iOS'), ('Android'), ('Panel físico/Papel'), ('Web');

CREATE TABLE entorno_uso (id SERIAL PRIMARY KEY, nombre TEXT UNIQUE NOT NULL);
INSERT INTO entorno_uso (id, nombre) VALUES (1, 'domicilio'), (2, 'exterior');

CREATE TABLE metodo_comunicacion (id SERIAL PRIMARY KEY, nombre TEXT UNIQUE NOT NULL);
INSERT INTO metodo_comunicacion (nombre) VALUES ('alfabeto'), ('pictogramas');

-- 3. TABLA DE SISTEMAS (Sin las columnas borradas)
CREATE TABLE saac_sistema (
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL,
    descripcion TEXT,
    requiere_interlocutor BOOLEAN,
    fatiga_fisica SMALLINT, 
    portable BOOLEAN,
    admite_anclaje BOOLEAN,
    enlace_info TEXT,
    categoria TEXT
); 

-- 4. CARGA DE SISTEMAS
INSERT INTO saac_sistema (nombre, descripcion, requiere_interlocutor, fatiga_fisica, portable, admite_anclaje, enlace_info, categoria)
VALUES
('Panel pictogramas','Tablero físico que utiliza símbolos pictográficos (ARASAAC).',true,0,true,true, 'https://arasaac.org/', 'sistema'),
('Panel alfabético','Tablero de comunicación directa mediante el deletreo.',true,0,true,true, 'https://downloads.tobiidynavox.com/Conditions/ALS/Communication_Board/TD_CommunicationBoard_ALS_es-ES.pdf', 'sistema'),
('SpeakBook','Cuaderno de comunicación diseñado para la selección mediante la mirada.',true,0,true,true, 'https://aulaabierta.arasaac.org/materiales-caa-tableros-de-comunicacion', 'sistema'),
('Tablero ETRAN','Panel transparente para comunicación mediante la dirección de la mirada.',true,0,true,true, 'https://downloads.tobiidynavox.com/Conditions/ALS/Communication_Board/TD_CommunicationBoard_ALS_es-ES.pdf', 'sistema'),
('QuickTalker 23','Comunicador portátil con 23 casillas para mensajes grabados.',false,0,true,false, 'https://qinera.com/es/tienda/comunicadores-sencillos/quick-talker-23', 'sistema'),
('MegaBEE', 'Escritura asistida por mirada y teclado táctil asistido por un interlocutor.', true, 0, true, true, 'https://www.e2l.uk.com/megabee/indexes.html', 'sistema'),
('Look to Speak','Mirada a través de cámara frontal para frases preestablecidas.',false,1,true,true, 'https://play.google.com/store/apps/details?id=com.androidexperiments.looktospeak', 'sistema'),
('Tallk','Seguimiento ocular a través de la cámara de la tablet (Samsung).',false,1,true,true, 'https://play.google.com/store/apps/details?id=com.irisbond.tallk', 'sistema'),
('Grid 3','Software integral para comunicación y control del entorno.',false,1,true,true, 'https://qinera.com/es/tienda/software-para-la-comunicacion/grid-3', 'sistema'),
('Verbo','Software de comunicación dinámico con salida de voz.',false,1,true,true, 'https://api.eneso.es/verbo', 'sistema'),
('Proloquo2Go','Comunicación simbólica para iOS basada en lenguaje natural.',false,2,true,true, 'https://www.assistiveware.com/es/productos/proloquo2go', 'sistema'),
('TD Snap','Software centrado en símbolos y navegación rápida.',false,1,true,true, 'https://apps.apple.com/es/app/td-snap/id1072799231', 'sistema'),
('Communicator 5','Software de comunicación eficiente para texto y símbolos.',false,1,true,true, 'https://qinera.com/es/tienda/software-para-la-comunicacion/communicator-5', 'sistema'),
('Boardmaker 7','Estándar para crear materiales basados en símbolos.',true,2,true,true, 'https://qinera.com/es/tienda/software-para-la-comunicacion/boardmaker-7', 'sistema'),
('Look to learn','Software de entrenamiento para el control ocular.',true,1,true,true, 'https://qinera.com/es/tienda/software-para-la-comunicacion/look-to-learn-1-licencia-electronica', 'sistema'),
('LetMeTalk','App de comunicación mediante pictogramas gratuita.',false,2,true,false, 'https://apps.apple.com/us/app/letmetalk-talker-saac-caa-sac/id919990138', 'sistema'),
('OptiKey', 'Teclado en pantalla gratuito optimizado para control ocular y Windows.', false, 1, true, true, 'https://www.optikey.org/', 'sistema'),
('Predictable', 'App de comunicación alfabética con predicción inteligente y acceso por pulsador.', false, 2, true, true, 'https://apps.apple.com/es/app/predictable/id404445007', 'sistema'),
('VirtualTEC', 'Comunicador personalizable para Android con acceso por pulsador.', false, 2, true, true, 'https://play.google.com/store/apps/details?id=com.uvigo.gti.VirtualTEC', 'sistema'),
('EVA Facial Mouse', 'Control del dispositivo Android mediante movimientos de la cabeza.', false, 2, true, true, 'https://easeapps.xyz/es/eva/', 'sistema'),
('Ease Touch', 'Facilita el uso de pantallas táctiles mediante pulsaciones simples o esperas.', false, 3, true, false, 'https://easeapps.xyz/es/ease-touch/', 'sistema'),
('Voice Access', 'App para controlar el móvil mediante la voz',false, 0, true, true, 'https://play.google.com/store/apps/details?id=com.google.android.apps.accessibility.voiceaccess&hl=es', 'sistema'),
('Asistente de voz AAC','Conversión de texto a voz.',false,1,true,false, 'https://play.google.com/store/apps/details?id=nl.asoft.speechassistant', 'sistema'),
('Speak4Me','App para reproducir frases rápidas guardadas.',false,1,true,false, 'https://apps.apple.com/es/app/speak4me-convertir-texto-a-voz/id894460403', 'sistema'),
('ComuniQa (TD Snap)','Pack tablet + seguimiento ocular + TD Snap.',false,1,true,true, 'https://qinera.com/es/tienda/comunicadores-de-mirada/comuniqa-eye-con-td-snap', 'sistema'),
('ComuniQa (Grid 3)','Pack tablet + seguimiento ocular + Grid 3.',false,1,true,true, 'https://qinera.com/es/tienda/comunicadores-de-mirada/comuniqa-eye-con-grid-3', 'sistema'),
('TD Pilot','Comunicador ocular de alta gama integrado para iPad.',false,1,true,true, 'https://qinera.com/es/tienda/comunicadores-de-mirada/TD-Pilot', 'sistema'),
('Amazon Alexa / Google Home', 'Asistente virtual para control doméstico.', false, 1, false, false, 'https://www.amazon.es/b?node=15712533031', 'sistema'),
('Enchufe Inteligente WiFi', 'Permite encender y apagar lámparas.', false, 0, false, false, NULL, 'hardware'),
('iPad', 'Tablet recomendada para iOS.', false, 0, true, true, 'https://www.apple.com/es/ipad/', 'hardware'),
('Tablet Android', 'Dispositivo versátil para Android.', false, 0, true, true, NULL, 'hardware'),
('Ordenador Portátil', 'Necesario para software avanzado.', false, 0, true, true, NULL, 'hardware'),
('Eye tracker', 'Lector ocular para control de dispositivos.', false, 1, false, true, 'https://www.irisbond.com/', 'hardware'),
('Puntero Láser', 'Señalización directa para tableros físicos.', true, 0, true, false, NULL, 'hardware'),
('Gafas con Puntero Láser', 'Puntero láser adaptado para control cefálico.', true, 1, true, false, 'https://www.elaandalucia.es/gafas-puntero-laser-todas-las-unidades-hospitalarias-ela-andalucia/', 'hardware'),
('Soporte de anclaje articulado', 'Brazo mecánico para fijación.', false, 0, false, true, 'https://qinera.com/es/tienda/comunicacion-aumentativa/soportes-y-brazos-caa', 'hardware'),
('Conmutador por soplido (Pufo)', 'Sensor de soplido.', false, 0, true, true, 'https://qinera.com/es/tienda/acceso-a-dispositivos-y-conmutadores/quha-pufo-con-kit-de-montaje-de-cabeza', 'hardware'),
('Conmutador de pedal', 'Pulsador para ser activado con el pie.', false, 1, true, false, 'https://qinera.com/es/tienda/ratones-y-pulsadores/conmutador-de-pedal', 'hardware'),
('Conmutador Spec Amarillo', 'Pulsador de fácil activación física.', false, 1, true, true, 'http://qinera.com/es/tienda/conmutadores/conmutador-spec-amarillo', 'hardware'),
('BJOY Chin Plus', 'Joystick de barbilla de alta precisión.', false, 1, true, true, 'https://qinera.com/es/tienda/ratones-y-pulsadores/bjoy-chin-plus', 'hardware'),
('Guantes antiincrustantes', 'Guante para evitar toques accidentales.', false, 0, true, false,'https://www.amazon.es/HUION-Tableta-Antiincrustante-Personas-Tabletas/dp/B00VTHAS00', 'hardware'),
('Lápiz táctil', 'Ergonómico para mayor precisión.', false, 1, true, false, 'https://goo.su/jnGcNM', 'hardware'),
('Ratón Bluetooth', 'Ratón inalámbrico ergonómico.', false, 1, true, true, 'https://goo.su/3XvwDat', 'hardware'),
('ModelTalker Gen3', 'Síntesis de voz personalizada.', false,2,true,false, 'https://modeltalker.org/', 'servicio'),
('MyOwnVoice (Acapela)', 'Voz digital idéntica.',false,1,true,false, 'https://mov.acapela-group.com/es/home-es/', 'servicio'),
('VocaliD', 'Hibridación de voz personalizada.',false,1,true,false, 'https://vocalid.ai/', 'servicio');

-- 5. EL RESTO DE TU CÓDIGO (Requisitos, Relaciones, etc.)
-- 5. TABLA DE REQUISITOS FUNCIONALES
-- Se definen los niveles mínimos (0-3) que debe tener el usuario para poder usar el SAAC
CREATE TABLE sistema_requisito_funcional (
    sistema_id INT PRIMARY KEY REFERENCES saac_sistema(id) ON DELETE CASCADE,
    nivel_visual_min SMALLINT,
    nivel_auditivo_min SMALLINT,
    nivel_tecnologico_min SMALLINT,
    nivel_habla_min SMALLINT);
INSERT INTO sistema_requisito_funcional 
(sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_tecnologico_min, nivel_habla_min)
VALUES
-- BAJA TECNOLOGÍA
((SELECT id FROM saac_sistema WHERE nombre = 'Panel pictogramas'), 1, 0, 0, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Panel alfabético'), 1, 0, 0, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'SpeakBook'), 1, 0, 0, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Tablero ETRAN'), 1, 0, 0, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'QuickTalker 23'), 1, 1, 2, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'MegaBEE'), 1, 0, 1, 0),

-- SOFTWARE Y APPS
((SELECT id FROM saac_sistema WHERE nombre = 'Look to Speak'), 2, 1, 1, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Tallk'), 2, 1, 1, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Grid 3'), 2, 1, 2, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Verbo'), 2, 1, 2, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Proloquo2Go'), 2, 1, 2, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'TD Snap'), 2, 1, 2, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Communicator 5'), 2, 1, 2, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Boardmaker 7'), 1, 1, 2, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Look to learn'), 2, 1, 1, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'LetMeTalk'), 2, 1, 2, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'OptiKey'), 2, 1, 1, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Predictable'), 2, 1, 2, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'VirtualTEC'), 1, 1, 2, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'EVA Facial Mouse'), 2, 1, 2, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Ease Touch'), 1, 1, 2, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Voice Access'), 0, 1, 2, 3),
((SELECT id FROM saac_sistema WHERE nombre = 'Asistente de voz AAC'), 2, 1, 1, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Speak4Me'), 2, 1, 2, 0),

-- PACKS COMPLETOS
((SELECT id FROM saac_sistema WHERE nombre = 'ComuniQa (TD Snap)'), 2, 1, 2, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'ComuniQa (Grid 3)'), 2, 1, 2, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'TD Pilot'), 2, 1, 2, 0),

-- DOMÓTICA
((SELECT id FROM saac_sistema WHERE nombre = 'Amazon Alexa / Google Home'), 0, 1, 2, 3),
((SELECT id FROM saac_sistema WHERE nombre = 'Enchufe Inteligente WiFi'), 2, 2, 2, 0),

-- HARDWARE BASE
((SELECT id FROM saac_sistema WHERE nombre = 'iPad'), 1, 1, 1, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Tablet Android'), 1, 1, 1, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Ordenador Portátil'), 1, 1, 1, 0),

-- PERIFÉRICOS
((SELECT id FROM saac_sistema WHERE nombre = 'Eye tracker'), 2, 1, 1, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Puntero Láser'), 2, 1, 0, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Gafas con Puntero Láser'), 2, 1, 0, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Soporte de anclaje articulado'), 0, 0, 0, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Conmutador por soplido (Pufo)'), 1, 1, 1, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Conmutador de pedal'), 1, 1, 0, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Conmutador Spec Amarillo'), 1, 1, 0, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'BJOY Chin Plus'), 1, 1, 1, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Guantes antiincrustantes'), 1, 1, 0, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Lápiz táctil'), 1, 1, 0, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Ratón Bluetooth'), 1, 1, 1, 0),

-- BANCOS DE VOZ
((SELECT id FROM saac_sistema WHERE nombre = 'ModelTalker Gen3'), 0, 1, 2, 3),
((SELECT id FROM saac_sistema WHERE nombre = 'MyOwnVoice (Acapela)'), 0, 1, 2, 3),
((SELECT id FROM saac_sistema WHERE nombre = 'VocaliD'), 0, 1, 2, 3);

-- 6. TABLAS DE RELACIÓN (Muchos a muchos)
-- Relacionan los sistemas con sus características (Entorno, entrada, idioma...)
CREATE TABLE sistema_entorno ( sistema_id INT REFERENCES saac_sistema(id) ON DELETE CASCADE, entorno_id INT REFERENCES entorno_uso(id) ON DELETE CASCADE, PRIMARY KEY (sistema_id, entorno_id));
CREATE TABLE sistema_entrada ( sistema_id INT REFERENCES saac_sistema(id) ON DELETE CASCADE, entrada_id INT REFERENCES tipo_entrada(id) ON DELETE CASCADE, PRIMARY KEY (sistema_id, entrada_id));
CREATE TABLE sistema_idioma ( sistema_id INT REFERENCES saac_sistema(id) ON DELETE CASCADE, idioma_id INT REFERENCES idioma(id) ON DELETE CASCADE, PRIMARY KEY (sistema_id, idioma_id));
CREATE TABLE sistema_plataforma ( sistema_id INT REFERENCES saac_sistema(id) ON DELETE CASCADE, plataforma_id INT REFERENCES plataforma(id) ON DELETE CASCADE, PRIMARY KEY (sistema_id, plataforma_id));
CREATE TABLE sistema_metodo ( sistema_id INT REFERENCES saac_sistema(id) ON DELETE CASCADE, metodo_id INT REFERENCES metodo_comunicacion(id) ON DELETE CASCADE, PRIMARY KEY (sistema_id, metodo_id));

-- 7. RELACIONES DE ENTRADA
-- Se define que entrada tiene cada sistema
-- Entrada manual o táctil
INSERT INTO sistema_entrada (sistema_id, entrada_id)
SELECT id, (SELECT id FROM tipo_entrada WHERE nombre = 'manos') FROM saac_sistema 
WHERE nombre IN ('Asistente de voz AAC','Panel pictogramas', 'Panel alfabético', 'SpeakBook', 'Puntero Láser', 'Proloquo2Go', 
	'Grid 3', 'Verbo', 'Boardmaker 7', 'QuickTalker 23', 'LetMeTalk', 'TD Snap', 'Guantes antiincrustantes',
	'Lápiz táctil', 'Ratón Bluetooth', 'Predictable', 'VirtualTEC', 'Ease Touch', 'iPad', 'Tablet Android', 
	'Ordenador Portátil', 'Enchufe Inteligente WiFi', 'Soporte de anclaje articulado', 'Speak4Me', 'Communicator 5');

-- Entrada ocular
INSERT INTO sistema_entrada (sistema_id, entrada_id)
SELECT id, (SELECT id FROM tipo_entrada WHERE nombre = 'ojos') FROM saac_sistema 
WHERE nombre IN ('Look to Speak', 'Eye tracker', 'Tablero ETRAN', 'Tallk', 'Look to learn', 
	'Grid 3', 'ComuniQa (TD Snap)', 'ComuniQa (Grid 3)', 'TD Pilot', 'Communicator 5', 'MegaBEE', 
	'OptiKey', 'Ordenador Portátil', 'SpeakBook', 'Panel pictogramas','Panel alfabético', 'Soporte de anclaje articulado');

-- Entrada cefálica
INSERT INTO sistema_entrada (sistema_id, entrada_id)
SELECT id, (SELECT id FROM tipo_entrada WHERE nombre = 'cabeza') FROM saac_sistema 
WHERE nombre IN ('EVA Facial Mouse', 'Grid 3', 'Verbo', 'Communicator 5', 'Gafas con Puntero Láser',
	'BJOY Chin Plus', 'Soporte de anclaje articulado');

-- Entrada por pulsador (sistemas con opción de barrido)
INSERT INTO sistema_entrada (sistema_id, entrada_id)
SELECT id, (SELECT id FROM tipo_entrada WHERE nombre = 'pulsador') FROM saac_sistema 
WHERE nombre IN ('Grid 3', 'Verbo', 'TD Snap', 'Predictable', 'VirtualTEC', 'Communicator 5',
    'QuickTalker 23', 'Conmutador por soplido (Pufo)', 'Conmutador de pedal', 'Conmutador Spec Amarillo', 'Soporte de anclaje articulado');

-- Entrada oral
INSERT INTO sistema_entrada (sistema_id, entrada_id)
SELECT id, (SELECT id FROM tipo_entrada WHERE nombre = 'voz') FROM saac_sistema 
WHERE nombre IN ( 'Amazon Alexa / Google Home', 'ModelTalker Gen3', 
	'MyOwnVoice (Acapela)', 'VocaliD', 'Voice Access', 'Soporte de anclaje articulado');

-- 8. RELACIONES DE IDIOMA
-- Se definen los idiomas en los que están cada sistema
-- Todos están en español
INSERT INTO sistema_idioma (sistema_id, idioma_id)
SELECT s.id, (SELECT id FROM idioma WHERE nombre = 'español') FROM saac_sistema s;

-- Catalán
INSERT INTO sistema_idioma (sistema_id, idioma_id)
SELECT id, (SELECT id FROM idioma WHERE nombre = 'catalán') FROM saac_sistema 
WHERE nombre IN (
    'Grid 3', 'Verbo', 'TD Snap', 'Proloquo2Go', 'Communicator 5', 'Boardmaker 7', 
    'LetMeTalk', 'Predictable', 'Tallk', 'OptiKey', 'Look to learn',
    'Panel pictogramas', 'Panel alfabético', 'SpeakBook', 'Tablero ETRAN', 
    'QuickTalker 23', 'MegaBEE', 'ComuniQa (TD Snap)', 'ComuniQa (Grid 3)', 'TD Pilot',
	'Amazon Alexa / Google Home','Eye tracker', 'iPad', 'Tablet Android', 'Ordenador Portátil', 
	'Puntero Láser', 'Gafas con Puntero Láser', 'Soporte de anclaje articulado', 
	'Conmutador por soplido (Pufo)',  'Conmutador de pedal', 'Conmutador Spec Amarillo', 
	'BJOY Chin Plus', 'Ratón Bluetooth');

-- Gallego
INSERT INTO sistema_idioma (sistema_id, idioma_id)
SELECT id, (SELECT id FROM idioma WHERE nombre = 'gallego') FROM saac_sistema 
WHERE nombre IN (
    'Grid 3', 'Verbo', 'TD Snap', 'Communicator 5', 'Boardmaker 7', 'VirtualTEC', 
	'OptiKey', 'Look to learn', 'Panel pictogramas', 'Panel alfabético', 'SpeakBook',
	'Tablero ETRAN', 'QuickTalker 23', 'MegaBEE','ComuniQa (TD Snap)', 'ComuniQa (Grid 3)', 
	'TD Pilot','Eye tracker', 'iPad', 'Tablet Android', 'Ordenador Portátil', 'Puntero Láser',
	'Gafas con Puntero Láser', 'Soporte de anclaje articulado', 'Conmutador por soplido (Pufo)', 
	'Conmutador de pedal', 'Conmutador Spec Amarillo', 'BJOY Chin Plus','Ratón Bluetooth');

-- Euskera
INSERT INTO sistema_idioma (sistema_id, idioma_id)
SELECT id, (SELECT id FROM idioma WHERE nombre = 'euskera') FROM saac_sistema 
WHERE nombre IN (
    'Grid 3', 'Verbo', 'TD Snap', 'Communicator 5', 'Boardmaker 7', 'OptiKey', 'Look to learn',
    'Panel pictogramas', 'Panel alfabético', 'SpeakBook', 'Tablero ETRAN', 'QuickTalker 23', 'MegaBEE',
    'ComuniQa (TD Snap)', 'ComuniQa (Grid 3)', 'TD Pilot','Eye tracker', 'iPad', 'Tablet Android',
	'Ordenador Portátil', 'Puntero Láser', 'Gafas con Puntero Láser', 'Soporte de anclaje articulado', 
	'Conmutador por soplido (Pufo)', 'Conmutador de pedal', 'Conmutador Spec Amarillo', 'BJOY Chin Plus',
	'Ratón Bluetooth');

-- 9. RELACIONES DE PLATAFORMA
-- Los sistemas operativos en los que se clasifica cada SAAC
-- Paneles físicos
INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, (SELECT id FROM plataforma WHERE nombre = 'Panel físico/Papel') FROM saac_sistema 
WHERE nombre IN ('Panel pictogramas', 'Panel alfabético', 'SpeakBook', 'Puntero Láser', 'Tablero ETRAN',
	'QuickTalker 23', 'Soporte de anclaje articulado', 'Conmutador de pedal', 'Conmutador Spec Amarillo', 
	'BJOY Chin Plus', 'MegaBEE', 'Gafas con Puntero Láser');

-- Windows (Ordenadores)
INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, (SELECT id FROM plataforma WHERE nombre = 'Windows') FROM saac_sistema 
WHERE nombre IN ('Grid 3', 'Eye tracker', 'Verbo', 'Look to learn', 'TD Snap', 'Communicator 5',
	'Boardmaker 7', 'OptiKey', 'Ordenador Portátil', 'ComuniQa (Grid3) ', 'ComuniQa (TD Snap)', 
	'Ratón Bluetooth', 'Conmutador por soplido (Pufo)', 'BJOY Chin Plus', 'Conmutador de pedal', 'Conmutador Spec Amarillo',
	'Conmutador por soplido (Pufo)', 'Soporte de anclaje articulado');

-- Android (Móviles o tablets)
INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, (SELECT id FROM plataforma WHERE nombre = 'Android') FROM saac_sistema 
WHERE nombre IN ('Look to Speak', 'Tallk', 'LetMeTalk', 'Guantes antiincrustantes', 'Lápiz táctil', 
	'VirtualTEC', 'EVA Facial Mouse', 'Ease Touch', 'Tablet Android', 'Enchufe Inteligente WiFi', 
	'Ratón Bluetooth', 'Conmutador por soplido (Pufo)', 'Asistente de voz AAC', 'Voice Access', 'BJOY Chin Plus',
	'Conmutador de pedal', 'Conmutador Spec Amarillo', 'Conmutador por soplido (Pufo)', 'Soporte de anclaje articulado');

-- iOs (iPhones o iPads)
INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, (SELECT id FROM plataforma WHERE nombre = 'iOS') FROM saac_sistema 
WHERE nombre IN ('Proloquo2Go', 'TD Snap', 'TD Pilot', 'LetMeTalk', 'Guantes antiincrustantes', 
	'Lápiz táctil', 'Predictable', 'iPad', 'Enchufe Inteligente WiFi', 'Ratón Bluetooth', 'Speak4Me',
	'Conmutador por soplido (Pufo)', 'Asistente de voz AAC', 'BJOY Chin Plus', 'Conmutador de pedal', 
	'Conmutador Spec Amarillo', 'Conmutador por soplido (Pufo)', 'Soporte de anclaje articulado');

-- Web (Navegador)
INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, (SELECT id FROM plataforma WHERE nombre = 'Web') FROM saac_sistema 
WHERE nombre IN ('Look to Speak', 'LetMeTalk', 'OptiKey', 'ModelTalker Gen3', 'MyOwnVoice (Acapela)', 
	'VocaliD', 'Amazon Alexa / Google Home', 'Boardmaker 7', 'Soporte de anclaje articulado');

-- 10.RELACIONES DE MÉTODO
-- Forma del lenguaje en la que prefieren comunicarse
INSERT INTO sistema_metodo (sistema_id, metodo_id)
SELECT id, (SELECT id FROM metodo_comunicacion WHERE nombre = 'alfabeto') FROM saac_sistema 
WHERE nombre IN ('Panel alfabético', 'Predictable', 'OptiKey', 'Communicator 5', 'MegaBEE', 
	'Asistente de voz AAC', 'Grid 3', 'Verbo', 'Speak4Me', 'Look to Speak', 'ComuniQa (Grid 3)',
	'ComuniQa (TD Snap)', 'TD Pilot', 'Eye tracker', 'Ratón Bluetooth', 'Lápiz táctil', 'Tablero ETRAN',
	'Amazon Alexa / Google Home', 'Enchufe Inteligente Wifi', 'iPad', 'Tablet Android', 'Ordenador Portátil',
	'ModelTalker Gen3', 'MyOwnVoice (Acapela)', 'VocaliD', 'EVA Facial Mouse', 'Ease Touch', 
    'Conmutador por soplido (Pufo)', 'Conmutador de pedal', 'Conmutador Spec Amarillo', 'BJOY Chin Plus', 
    'Guantes antiincrustantes', 'Soporte de anclaje articulado', 'Voice Access');

INSERT INTO sistema_metodo (sistema_id, metodo_id)
SELECT id, (SELECT id FROM metodo_comunicacion WHERE nombre = 'pictogramas') FROM saac_sistema 
WHERE nombre IN ('Panel pictogramas', 'SpeakBook', 'TD Snap', 'LetMeTalk', 'Proloquo2Go', 'QuickTalker 23',
	'Grid 3', 'Verbo', 'Boardmaker 7', 'VirtualTEC', 'Tallk', 'ComuniQa (Grid 3)', 'ComuniQa (TD Snap)', 
	'TD Pilot', 'Eye tracker', 'Ratón Bluetooth', 'Lápiz táctil', 'Look to Speak', 'EVA Facial Mouse', 
	'Ease Touch', 'Conmutador por soplido (Pufo)', 'Conmutador de pedal', 'Conmutador Spec Amarillo', 
	'BJOY Chin Plus', 'Guantes antiincrustantes', 'Soporte de anclaje articulado' );

-- 11. RELACIONES DE ENTORNO
-- Donde se va a utilizar el sistema, en domicilio todos, en exterior solo algunos
INSERT INTO sistema_entorno (sistema_id, entorno_id) SELECT id, 1 FROM saac_sistema;
INSERT INTO sistema_entorno (sistema_id, entorno_id)
SELECT id, 2 FROM saac_sistema 
WHERE nombre IN ('Panel pictogramas', 'Panel alfabético', 'SpeakBook', 'Tablero ETRAN', 'QuickTalker 23', 
	'iPad', 'Tablet Android', 'Look to Speak', 'Tallk', 'Predictable', 'VirtualTEC', 
	'Asistente de voz AAC', 'Speak4Me', 'Voice Access', 'Soporte de anclaje articulado');

-- 12. RELACIONES SAAC-PERIFÉRICOS
-- Tabla de asignación de periféricos
CREATE TABLE sistema_dependencia (
    sistema_id INT REFERENCES saac_sistema(id) ON DELETE CASCADE,
    hardware_requerido_id INT REFERENCES saac_sistema(id) ON DELETE CASCADE,
    es_opcional BOOLEAN DEFAULT FALSE, -- Por si el hardware es una mejora pero no vital
    PRIMARY KEY (sistema_id, hardware_requerido_id));

-- Los softwares de PC requieren un 'Ordenador Portátil'
INSERT INTO sistema_dependencia (sistema_id, hardware_requerido_id)
SELECT id, (SELECT id FROM saac_sistema WHERE nombre = 'Ordenador Portátil')
FROM saac_sistema WHERE nombre IN ('Grid 3', 'Verbo', 'Communicator 5', 'Look to learn', 
	'OptiKey', 'Boardmaker 7', 'TD Snap', 'Eye tracker', 'BJOY Chin Plus', 'OptiKey', 'Ratón Bluetooth')
ON CONFLICT DO NOTHING;

-- Los sistemas iOS requieren iPad
INSERT INTO sistema_dependencia (sistema_id, hardware_requerido_id)
SELECT id, (SELECT id FROM saac_sistema WHERE nombre = 'iPad')
FROM saac_sistema WHERE nombre IN ('Proloquo2Go', 'Predictable', 'Speak4Me', 'TD Snap', 'Lápiz táctil',
	'Guantes antiincrustantes','Ratón Bluetooth')
ON CONFLICT DO NOTHING;

-- Los sistemas Android requieren Tablet Android
INSERT INTO sistema_dependencia (sistema_id, hardware_requerido_id)
SELECT id, (SELECT id FROM saac_sistema WHERE nombre = 'Tablet Android')
FROM saac_sistema WHERE nombre IN ('Tallk', 'VirtualTEC', 'EVA Facial Mouse', 'Ease Touch', 
	'Voice Access', 'Asistente de voz AAC', 'Look to Speak', 'LetMeTalk', 'TD Snap', 'Lápiz táctil',
	'Guantes antiincrustantes','Ratón Bluetooth')
ON CONFLICT DO NOTHING;

-- Queremos que si sale una App de Tablet, se sugieran los accesorios de precisión.
INSERT INTO sistema_dependencia (sistema_id, hardware_requerido_id)
SELECT id, (SELECT id FROM saac_sistema WHERE nombre = 'Lápiz táctil')
FROM saac_sistema WHERE nombre IN ('Proloquo2Go', 'TD Snap', 'LetMeTalk', 'Asistente de voz AAC', 
	'Predictable', 'VirtualTEC')
ON CONFLICT DO NOTHING;

INSERT INTO sistema_dependencia (sistema_id, hardware_requerido_id)
SELECT id, (SELECT id FROM saac_sistema WHERE nombre = 'Guantes antiincrustantes')
FROM saac_sistema WHERE nombre IN ('Proloquo2Go', 'TD Snap', 'LetMeTalk', 'VirtualTEC')
ON CONFLICT DO NOTHING;

-- Software compatible con soplido
INSERT INTO sistema_dependencia (sistema_id, hardware_requerido_id)
SELECT id, (SELECT id FROM saac_sistema WHERE nombre = 'BJOY Chin Plus')
FROM saac_sistema WHERE nombre IN ('Grid 3', 'Verbo', 'Communicator 5', 'OptiKey')
ON CONFLICT DO NOTHING;

-- Software que se beneficia de Ratón Bluetooth (Usuarios con movilidad reducida pero funcional)
INSERT INTO sistema_dependencia (sistema_id, hardware_requerido_id)
SELECT id, (SELECT id FROM saac_sistema WHERE nombre = 'Ratón Bluetooth')
FROM saac_sistema WHERE nombre IN ('Proloquo2Go', 'TD Snap', 'LetMeTalk', 'Predictable', 
	'Asistente de voz AAC')
ON CONFLICT DO NOTHING;
	
-- Todo hardware pesado o de alta tecnología requiere anclaje por seguridad y precisión
INSERT INTO sistema_dependencia (sistema_id, hardware_requerido_id)
SELECT id, (SELECT id FROM saac_sistema WHERE nombre = 'Soporte de anclaje articulado')
FROM saac_sistema WHERE nombre IN 
('Ordenador Portátil', 'iPad', 'Tablet Android', 'TD Pilot', 'ComuniQa (TD Snap)', 'ComuniQa (Grid 3)',
	'Tablero ETRAN', 'MegaBEE', 'SpeakBook')
ON CONFLICT DO NOTHING;

-- Requieren seguimiento ocular (Software -> Periférico)
INSERT INTO sistema_dependencia (sistema_id, hardware_requerido_id)
SELECT id, (SELECT id FROM saac_sistema WHERE nombre = 'Eye tracker')
FROM saac_sistema WHERE nombre IN ('Grid 3', 'Communicator 5', 'Look to learn', 'OptiKey', 'TD Snap')
ON CONFLICT DO NOTHING;

-- Pulsadores y métodos de barrido (Software -> Periférico)
INSERT INTO sistema_dependencia (sistema_id, hardware_requerido_id)
SELECT id, (SELECT id FROM saac_sistema WHERE nombre = 'Conmutador de pedal')
FROM saac_sistema WHERE nombre IN ('Grid 3', 'Verbo', 'Communicator 5', 'Predictable', 'VirtualTEC')
ON CONFLICT DO NOTHING;

INSERT INTO sistema_dependencia (sistema_id, hardware_requerido_id)
SELECT id, (SELECT id FROM saac_sistema WHERE nombre = 'Conmutador Spec Amarillo')
FROM saac_sistema WHERE nombre IN ('Predictable', 'VirtualTEC', 'QuickTalker 23')
ON CONFLICT DO NOTHING;

INSERT INTO sistema_dependencia (sistema_id, hardware_requerido_id)
SELECT id, (SELECT id FROM saac_sistema WHERE nombre = 'Conmutador por soplido (Pufo)')
FROM saac_sistema WHERE nombre IN ('Grid 3', 'Verbo', 'Communicator 5', 'VirtualTEC')
ON CONFLICT DO NOTHING;

-- Baja Tecnología (Sistemas -> Periféricos físicos)
INSERT INTO sistema_dependencia (sistema_id, hardware_requerido_id)
SELECT id, (SELECT id FROM saac_sistema WHERE nombre = 'Puntero Láser')
FROM saac_sistema WHERE nombre IN ('Panel pictogramas', 'Panel alfabético')
ON CONFLICT DO NOTHING;

INSERT INTO sistema_dependencia (sistema_id, hardware_requerido_id)
SELECT id, (SELECT id FROM saac_sistema WHERE nombre = 'Gafas con Puntero Láser')
FROM saac_sistema WHERE nombre IN ('Panel pictogramas', 'Panel alfabético')
ON CONFLICT DO NOTHING;

-- Domótica
INSERT INTO sistema_dependencia (sistema_id, hardware_requerido_id)
SELECT id, (SELECT id FROM saac_sistema WHERE nombre = 'Enchufe Inteligente WiFi')
FROM saac_sistema WHERE nombre = 'Amazon Alexa / Google Home'
ON CONFLICT DO NOTHING;

-- 13. TABLA HISTORIAL
-- Guardado
CREATE TABLE historial_recomendacion (
    id SERIAL PRIMARY KEY,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    nombre_paciente VARCHAR(100),
    input_usuario JSONB, 
    sistemas_recomendados TEXT,
    feedback JSON,
	es_real BOOLEAN
);

SELECT * FROM historial_recomendacion;
COMMIT;