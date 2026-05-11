-- 1. LIMPIEZA TOTAL DE TABLAS
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

-- 2. TABLAS MAESTRAS
-- Métodos físicos de interacción
CREATE TABLE tipo_entrada (
    id SERIAL PRIMARY KEY,
    nombre TEXT UNIQUE NOT NULL);
INSERT INTO tipo_entrada (nombre) VALUES
('manos'), ('ojos'), ('cabeza'), ('voz'), ('pulsador');

-- Idiomas soportados
CREATE TABLE idioma (
    id SERIAL PRIMARY KEY,
    nombre TEXT UNIQUE NOT NULL);
INSERT INTO idioma (nombre) VALUES
('español'), ('gallego'), ('catalán'), ('euskera');

-- Sistemas operativos 
CREATE TABLE plataforma (
    id SERIAL PRIMARY KEY,
    nombre TEXT UNIQUE NOT NULL);
INSERT INTO plataforma (nombre) VALUES 
('Windows'), ('iOS'), ('Android'), ('Panel físico/Papel'), ('Web');

-- Entornos de uso
CREATE TABLE entorno_uso (
    id SERIAL PRIMARY KEY,
    nombre TEXT UNIQUE NOT NULL);
INSERT INTO entorno_uso (id, nombre) VALUES (1, 'domicilio'), (2, 'exterior');

-- Formas de comunicación
CREATE TABLE metodo_comunicacion (
    id SERIAL PRIMARY KEY,
    nombre TEXT UNIQUE NOT NULL);
INSERT INTO metodo_comunicacion (nombre) VALUES ('alfabeto'), ('pictogramas');

-- 3. TABLA DE SISTEMAS SAAC
-- Contiene la info descriptiva de cada SAAC, hardware y servicio
CREATE TABLE saac_sistema (
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL,
    descripcion TEXT,
    coste_min NUMERIC,
    requiere_interlocutor BOOLEAN, -- Si necesita de otra persona para comunicarse o proporciona autonomía
    fatiga_fisica SMALLINT, 
    portable BOOLEAN, -- Si es fácil de transportar
    admite_anclaje BOOLEAN, -- Si puede anexarse a la silla o similares
    enlace_info TEXT, -- Enlace con más información del producto (página de los desarrolladores o vendedores)
    categoria TEXT, -- Si es un sistema, un periférico o un servicio de banco de voz
    requiere_hardware_extra BOOLEAN DEFAULT FALSE ); 
-- 4. CARGA DE SISTEMAS 
INSERT INTO saac_sistema 
(nombre, descripcion, requiere_interlocutor, fatiga_fisica, portable, admite_anclaje, enlace_info, categoria, requiere_hardware_extra)
VALUES
-- BAJA TECNOLOGÍA
('Panel pictogramas','Tablero físico que utiliza símbolos pictográficos (ARASAAC).',true,0,true,true, 'https://arasaac.org/', 'sistema', false),
('Panel alfabético','Tablero de comunicación directa mediante el deletreo.',true,0,true,true, 'https://downloads.tobiidynavox.com/Conditions/ALS/Communication_Board/TD_CommunicationBoard_ALS_es-ES.pdf', 'sistema', false),
('SpeakBook','Cuaderno de comunicación diseñado para la selección mediante la mirada.',true,0,true,true, 'https://aulaabierta.arasaac.org/materiales-caa-tableros-de-comunicacion', 'sistema', false),
('Tablero ETRAN','Panel transparente para comunicación mediante la dirección de la mirada.',true,0,true,true, 'https://downloads.tobiidynavox.com/Conditions/ALS/Communication_Board/TD_CommunicationBoard_ALS_es-ES.pdf', 'sistema', false),
('QuickTalker 23','Comunicador portátil con 23 casillas para mensajes grabados.',false,0,true,false, 'https://qinera.com/es/tienda/comunicadores-sencillos/quick-talker-23', 'sistema', false),
('MegaBEE', 'Escritura asistida por mirada y teclado táctil asistido por un interlocutor.', true, 0, true, true, 'https://www.e2l.uk.com/megabee/indexes.html', 'sistema', false),

-- SOFTWARE Y APPS (Look to Speak y Tallk NO requieren hardware extra porque usan su propia cámara integrada)
('Look to Speak','Mirada a través de cámara frontal para frases preestablecidas.',false,1,true,true, 'https://play.google.com/store/apps/details?id=com.androidexperiments.looktospeak', 'sistema', false),
('Tallk','Seguimiento ocular a través de la cámara de la tablet (Samsung).',false,1,true,true, 'https://play.google.com/store/apps/details?id=com.irisbond.tallk', 'sistema', false),
('Grid 3','Software integral para comunicación y control del entorno.',false,1,true,true, 'https://qinera.com/es/tienda/software-para-la-comunicacion/grid-3', 'sistema', true),
('Verbo','Software de comunicación dinámico con salida de voz.',false,1,true,true, 'https://api.eneso.es/verbo', 'sistema', true),
('Proloquo2Go','Comunicación simbólica para iOS basada en lenguaje natural.',false,2,true,true, 'https://www.assistiveware.com/es/productos/proloquo2go', 'sistema', false),
('TD Snap','Software centrado en símbolos y navegación rápida.',false,1,true,true, 'https://apps.apple.com/es/app/td-snap/id1072799231', 'sistema', false),
('Communicator 5','Software de comunicación eficiente para texto y símbolos.',false,1,true,true, 'https://qinera.com/es/tienda/software-para-la-comunicacion/communicator-5', 'sistema', true),
('Boardmaker 7','Estándar para crear materiales basados en símbolos.',true,2,true,true, 'https://qinera.com/es/tienda/software-para-la-comunicacion/boardmaker-7', 'sistema', false),
('Look to learn','Software de entrenamiento para el control ocular.',true,1,true,true, 'https://qinera.com/es/tienda/software-para-la-comunicacion/look-to-learn-1-licencia-electronica', 'sistema', true),
('LetMeTalk','App de comunicación mediante pictogramas gratuita.',false,2,true,false, 'https://apps.apple.com/us/app/letmetalk-talker-saac-caa-sac/id919990138', 'sistema', false),
('OptiKey', 'Teclado en pantalla gratuito optimizado para control ocular y Windows.', false, 1, true, true, 'https://www.optikey.org/', 'sistema', true),
('Predictable', 'App de comunicación alfabética con predicción inteligente y acceso por pulsador.', false, 2, true, true, 'https://apps.apple.com/es/app/predictable/id404445007', 'sistema', false),
('VirtualTEC', 'Comunicador personalizable para Android con acceso por pulsador.', false, 2, true, true, 'https://play.google.com/store/apps/details?id=com.uvigo.gti.VirtualTEC', 'sistema', false),
('EVA Facial Mouse', 'Control del dispositivo Android mediante movimientos de la cabeza.', false, 2, true, true, 'https://easeapps.xyz/es/eva/', 'sistema', false),
('Ease Touch', 'Facilita el uso de pantallas táctiles mediante pulsaciones simples o esperas.', false, 3, true, false, 'https://easeapps.xyz/es/ease-touch/', 'sistema', false),

-- VOZ
('Asistente de voz AAC','Conversión de voz a texto.',false,1,true,false, 'https://play.google.com/store/apps/details?id=nl.asoft.speechassistant', 'sistema', false),
('Speak4Me','App para reproducir frases rápidas guardadas.',false,1,true,false, 'https://speak4me.io/', 'sistema', false),

-- PACKS COMPLETOS
('ComuniQa (TD Snap)','Pack tablet + seguimiento ocular + TD Snap.',false,1,true,true, 'https://qinera.com/es/tienda/comunicadores-de-mirada/comuniqa-eye-con-td-snap', 'sistema', false),
('ComuniQa (Grid 3)','Pack tablet + seguimiento ocular + Grid 3.',false,1,true,true, 'https://qinera.com/es/tienda/comunicadores-de-mirada/comuniqa-eye-con-grid-3', 'sistema', false),
('TD Pilot','Comunicador ocular de alta gama integrado para iPad.',false,1,true,true, 'https://qinera.com/es/tienda/comunicadores-de-mirada/TD-Pilot', 'sistema', false),

-- DOMÓTICA
('Amazon Alexa / Google Home', 'Asistente virtual para control doméstico.', false, 1, false, false, 'https://www.amazon.es/b?node=15712533031', 'sistema', false),
('Enchufe Inteligente WiFi', 'Permite encender y apagar lámparas.', false, 0, false, false, NULL, 'hardware', false),

-- HARDWARE
('iPad', 'Tablet recomendada para iOS.', false, 0, true, true, 'https://www.apple.com/es/ipad/', 'hardware', false),
('Tablet Android', 'Dispositivo versátil para Android.', false, 0, true, true, NULL, 'hardware', false),
('Ordenador Portátil', 'Necesario para software avanzado.', false, 0, true, true, NULL, 'hardware', false),

-- PERIFÉRICOS
('Eye tracker','Lector ocular para control de dispositivos.',false,1,false,true, 'https://www.irisbond.com/', 'hardware', false),
('Puntero Láser','Señalización directa para tableros físicos.',true,0,true,false, NULL, 'hardware', false),
('Gafas con Puntero Láser', 'Puntero láser adaptado para control cefálico.',true,1,true,false, 'https://www.elaandalucia.es/gafas-puntero-laser-todas-las-unidades-hospitalarias-ela-andalucia/', 'hardware', false),
('Soporte de anclaje articulado', 'Brazo mecánico para fijación.',false,0,false,true, 'https://qinera.com/es/tienda/comunicacion-aumentativa/soportes-y-brazos-caa', 'hardware', false),
('Conmutador por soplido (Pufo)', 'Sensor de soplido.', false, 0, true, true, 'https://qinera.com/es/tienda/acceso-a-dispositivos-y-conmutadores/quha-pufo-con-kit-de-montaje-de-cabeza', 'hardware', false),
('Conmutador de pedal', 'Pulsador para ser activado con el pie.', false, 1, true, false, 'https://qinera.com/es/tienda/ratones-y-pulsadores/conmutador-de-pedal', 'hardware', false),
('Conmutador Spec Amarillo', 'Pulsador de fácil activación física.', false, 1, true, true, 'http://qinera.com/es/tienda/conmutadores/conmutador-spec-amarillo', 'hardware', false),
('BJOY Chin Plus', 'Joystick de barbilla de alta precisión.', false, 1, true, true, 'https://qinera.com/es/tienda/ratones-y-pulsadores/bjoy-chin-plus', 'hardware', false),
('Guantes antiincrustantes', 'Guante para evitar toques accidentales.', false, 0, true, false,'https://www.amazon.es/HUION-Tableta-Antiincrustante-Personas-Tabletas/dp/B00VTHAS00', 'hardware', false),
('Lápiz táctil', 'Ergonómico para mayor precisión.', false, 1, true, false, 'https://goo.su/jnGcNM', 'hardware', false),
('Ratón Bluetooth', 'Ratón inalámbrico ergonómico.', false, 1, true, true, 'https://goo.su/3XvwDat', 'hardware', false),

-- BANCOS DE VOZ
('ModelTalker Gen3', 'Síntesis de voz personalizada.', false,2,true,false, 'https://modeltalker.org/', 'servicio', false),
('MyOwnVoice (Acapela)', 'Voz digital idéntica.',false,1,true,false, 'https://mov.acapela-group.com/es/home-es/', 'servicio', false),
('VocaliD', 'Hibridación de voz personalizada.',false,1,true,false, 'https://vocalid.ai/', 'servicio', false);

-- REQUISITOS DE LOS SISTEMAS
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
((SELECT id FROM saac_sistema WHERE nombre = 'Panel pictogramas'), 2, 0, 0, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Panel alfabético'), 2, 0, 0, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'SpeakBook'), 2, 0, 0, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Tablero ETRAN'), 2, 0, 0, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'QuickTalker 23'), 1, 1, 2, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'MegaBEE'), 2, 0, 1, 0),

-- SOFTWARE Y APPS
((SELECT id FROM saac_sistema WHERE nombre = 'Look to Speak'), 2, 1, 1, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Tallk'), 2, 1, 1, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Grid 3'), 2, 2, 2, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Verbo'), 2, 2, 2, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Proloquo2Go'), 2, 1, 2, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'TD Snap'), 2, 2, 2, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Communicator 5'), 2, 2, 2, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Boardmaker 7'), 1, 1, 2, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Look to learn'), 2, 1, 1, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'LetMeTalk'), 2, 1, 2, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'OptiKey'), 2, 1, 1, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Predictable'), 2, 2, 2, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'VirtualTEC'), 1, 1, 2, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'EVA Facial Mouse'), 2, 2, 2, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'Ease Touch'), 1, 1, 2, 0),

-- VOZ
((SELECT id FROM saac_sistema WHERE nombre = 'Asistente de voz AAC'), 2, 1, 2, 3),
((SELECT id FROM saac_sistema WHERE nombre = 'Speak4Me'), 2, 1, 2, 0),

-- PACKS COMPLETOS
((SELECT id FROM saac_sistema WHERE nombre = 'ComuniQa (TD Snap)'), 2, 2, 2, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'ComuniQa (Grid 3)'), 2, 2, 2, 0),
((SELECT id FROM saac_sistema WHERE nombre = 'TD Pilot'), 2, 2, 2, 0),

-- DOMÓTICA
((SELECT id FROM saac_sistema WHERE nombre = 'Amazon Alexa / Google Home'), 1, 1, 2, 3),
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
WHERE nombre IN ('Panel pictogramas', 'Panel alfabético', 'SpeakBook', 'Puntero Láser', 'Proloquo2Go', 
	'Grid 3', 'Verbo', 'Boardmaker 7', 'QuickTalker 23', 'LetMeTalk', 'TD Snap', 'Guantes antiincrustantes',
	'Lápiz táctil', 'Ratón Bluetooth', 'Predictable', 'VirtualTEC', 'Ease Touch', 'iPad', 'Tablet Android', 
	'Ordenador Portátil', 'Enchufe Inteligente WiFi', 'Soporte de anclaje articulado', 'Speak4Me');

-- Entrada ocular
INSERT INTO sistema_entrada (sistema_id, entrada_id)
SELECT id, (SELECT id FROM tipo_entrada WHERE nombre = 'ojos') FROM saac_sistema 
WHERE nombre IN ('Look to Speak', 'Eye tracker', 'Tablero ETRAN', 'Tallk', 'Look to learn', 
	'Grid 3', 'ComuniQa (TD Snap)', 'ComuniQa (Grid 3)', 'TD Pilot', 'Communicator 5', 'MegaBEE', 
	'OptiKey', 'Ordenador Portátil', 'SpeakBook', 'Panel pictogramas','Panel alfabético');

-- Entrada cefálica
INSERT INTO sistema_entrada (sistema_id, entrada_id)
SELECT id, (SELECT id FROM tipo_entrada WHERE nombre = 'cabeza') FROM saac_sistema 
WHERE nombre IN ('EVA Facial Mouse', 'Grid 3', 'Verbo', 'Communicator 5', 'Gafas con Puntero Láser',
	'BJOY Chin Plus');

-- Entrada por pulsador (sistemas con opción de barrido)
INSERT INTO sistema_entrada (sistema_id, entrada_id)
SELECT id, (SELECT id FROM tipo_entrada WHERE nombre = 'pulsador') FROM saac_sistema 
WHERE nombre IN ('Grid 3', 'Verbo', 'TD Snap', 'Predictable', 'VirtualTEC', 'Communicator 5',
    'QuickTalker 23', 'Conmutador por soplido (Pufo)', 'Conmutador de pedal', 'Conmutador Spec Amarillo');

-- Entrada oral
INSERT INTO sistema_entrada (sistema_id, entrada_id)
SELECT id, (SELECT id FROM tipo_entrada WHERE nombre = 'voz') FROM saac_sistema 
WHERE nombre IN ('Asistente de voz AAC', 'Amazon Alexa / Google Home', 'ModelTalker Gen3', 
	'MyOwnVoice (Acapela)', 'VocaliD');

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
	'Ratón Bluetooth', 'Conmutador por soplido (Pufo)');

-- Android (Móviles o tablets)
INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, (SELECT id FROM plataforma WHERE nombre = 'Android') FROM saac_sistema 
WHERE nombre IN ('Look to Speak', 'Tallk', 'LetMeTalk', 'Guantes antiincrustantes', 'Lápiz táctil', 
	'VirtualTEC', 'EVA Facial Mouse', 'Ease Touch', 'Tablet Android', 'Enchufe Inteligente WiFi', 
	'Ratón Bluetooth', 'Conmutador por soplido (Pufo)', 'Asistente de voz AAC');

-- iOs (iPhones o iPads)
INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, (SELECT id FROM plataforma WHERE nombre = 'iOS') FROM saac_sistema 
WHERE nombre IN ('Proloquo2Go', 'TD Snap', 'TD Pilot', 'LetMeTalk', 'Guantes antiincrustantes', 
	'Lápiz táctil', 'Predictable', 'iPad', 'Enchufe Inteligente WiFi', 'Ratón Bluetooth', 'Speak4Me',
	'Conmutador por soplido (Pufo)', 'Asistente de voz AAC');

-- Web (Navegador)
INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, (SELECT id FROM plataforma WHERE nombre = 'Web') FROM saac_sistema 
WHERE nombre IN ('Look to Speak', 'LetMeTalk', 'OptiKey', 'ModelTalker Gen3', 'MyOwnVoice (Acapela)', 
	'VocaliD', 'Amazon Alexa / Google Home', 'Boardmaker 7');

-- RELACIONES DE MÉTODO
-- Forma del lenguaje en la que prefieren comunicarse
INSERT INTO sistema_metodo (sistema_id, metodo_id)
SELECT id, (SELECT id FROM metodo_comunicacion WHERE nombre = 'alfabeto') FROM saac_sistema 
WHERE nombre IN ('Panel alfabético', 'Predictable', 'OptiKey', 'Communicator 5', 'MegaBEE', 
	'Asistente de voz AAC', 'Grid 3', 'Verbo', 'Speak4Me', 'Look to Speak', 'ComuniQa (Grid 3)',
	'ComuniQa (TD Snap)', 'TD Pilot', 'Eye tracker', 'Ratón Bluetooth', 'Lápiz táctil', 'Tablero ETRAN',
	'Amazon Alexa / Google Home', 'Enchufe Inteligente Wifi', 'iPad', 'Tablet Android', 'Ordenador Portátil',
	'ModelTalker Gen3', 'MyOwnVoice (Acapela)', 'VocaliD', 'EVA Facial Mouse', 'Ease Touch', 
    'Conmutador por soplido (Pufo)', 'Conmutador de pedal', 'Conmutador Spec Amarillo', 'BJOY Chin Plus', 
    'Guantes antiincrustantes', 'Soporte de anclaje articulado');

INSERT INTO sistema_metodo (sistema_id, metodo_id)
SELECT id, (SELECT id FROM metodo_comunicacion WHERE nombre = 'pictogramas') FROM saac_sistema 
WHERE nombre IN ('Panel pictogramas', 'SpeakBook', 'TD Snap', 'LetMeTalk', 'Proloquo2Go', 'QuickTalker 23',
	'Grid 3', 'Verbo', 'Boardmaker 7', 'VirtualTEC', 'Tallk', 'ComuniQa (Grid 3)', 'ComuniQa (TD Snap)', 
	'TD Pilot', 'Eye tracker', 'Ratón Bluetooth', 'Lápiz táctil', 'Look to Speak', 'EVA Facial Mouse', 
	'Ease Touch', 'Conmutador por soplido (Pufo)', 'Conmutador de pedal', 'Conmutador Spec Amarillo', 
	'BJOY Chin Plus', 'Guantes antiincrustantes', 'Soporte de anclaje articulado' );

-- RELACIONES DE ENTORNO
-- Donde se va a utilizar el sistema, en domicilio todos, en exterior solo algunos
INSERT INTO sistema_entorno (sistema_id, entorno_id) SELECT id, 1 FROM saac_sistema;
INSERT INTO sistema_entorno (sistema_id, entorno_id)
SELECT id, 2 FROM saac_sistema 
WHERE nombre IN ('Panel pictogramas', 'Panel alfabético', 'SpeakBook', 'Tablero ETRAN', 'QuickTalker 23', 
	'iPad', 'Tablet Android', 'Look to Speak', 'Tallk', 'Predictable', 'VirtualTEC', 
	'Asistente de voz AAC', 'Speak4Me');

-- 10. TABLA HISTORIAL
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