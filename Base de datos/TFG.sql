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
('Windows'), ('iOS'), ('Android'), ('Panel físico/Papel'), ('Web');

CREATE TABLE entorno_uso (
    id SERIAL PRIMARY KEY,
    nombre TEXT UNIQUE NOT NULL
);
INSERT INTO entorno_uso (id, nombre) VALUES (1, 'domicilio'), (2, 'exterior');

CREATE TABLE metodo_comunicacion (
    id SERIAL PRIMARY KEY,
    nombre TEXT UNIQUE NOT NULL
);
INSERT INTO metodo_comunicacion (nombre) VALUES ('alfabeto'), ('pictogramas');

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
    enlace_info TEXT,
    categoria TEXT,
    requiere_hardware_extra BOOLEAN DEFAULT FALSE -- Clave para evitar recomendaciones innecesarias
);

-- 4. CARGA DE SISTEMAS (Sistemas y Periféricos con sus enlaces intactos)
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

-- SOFTWARE Y APPS (Look to Speak y Tallk NO requieren hardware extra porque usan cámara)
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

-- 5. TABLA DE REQUISITOS FUNCIONALES (Corregida con nombres unificados)
CREATE TABLE sistema_requisito_funcional (
    sistema_id INT PRIMARY KEY REFERENCES saac_sistema(id) ON DELETE CASCADE,
    nivel_visual_min SMALLINT DEFAULT 0,
    nivel_auditivo_min SMALLINT DEFAULT 0,
    nivel_tecnologico_min SMALLINT DEFAULT 0,
    nivel_habla_min SMALLINT DEFAULT 0
);

INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_tecnologico_min, nivel_habla_min)
SELECT id, 3, 1, 2, 0 FROM saac_sistema 
WHERE nombre IN ('Eye tracker', 'Tallk', 'Look to Speak', 'MegaBEE', 'Look to learn', 'Panel pictogramas', 'Panel alfabético', 'SpeakBook', 'Tablero ETRAN', 'Puntero Láser', 'Gafas con Puntero Láser', 'OptiKey');

INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_tecnologico_min, nivel_habla_min)
SELECT id, 2, 2, 3, 0 FROM saac_sistema 
WHERE nombre IN ('Grid 3', 'Verbo', 'TD Snap', 'ComuniQa (TD Snap)', 'ComuniQa (Grid 3)', 'Communicator 5', 'TD Pilot', 'Predictable', 'EVA Facial Mouse', 'Enchufe Inteligente WiFi');

INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_tecnologico_min, nivel_habla_min)
SELECT id, 1, 1, 2, 0 FROM saac_sistema 
WHERE nombre IN ('Boardmaker 7', 'QuickTalker 23', 'Conmutador por soplido (Pufo)', 'Conmutador de pedal', 'Conmutador Spec Amarillo', 'BJOY Chin Plus', 'Guantes antiincrustantes', 'Lápiz táctil', 'Ratón Bluetooth', 'VirtualTEC', 'Ease Touch', 'iPad', 'Tablet Android', 'Ordenador Portátil');

INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_tecnologico_min, nivel_habla_min)
SELECT id, 1, 1, 2, 3 FROM saac_sistema WHERE nombre = 'Amazon Alexa / Google Home';

INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_tecnologico_min, nivel_habla_min)
SELECT id, 0, 1, 2, 3 FROM saac_sistema 
WHERE nombre IN ('ModelTalker Gen3', 'MyOwnVoice (Acapela)', 'VocaliD');

-- 6. TABLAS DE RELACIÓN
CREATE TABLE sistema_entorno ( sistema_id INT REFERENCES saac_sistema(id) ON DELETE CASCADE, entorno_id INT REFERENCES entorno_uso(id) ON DELETE CASCADE, PRIMARY KEY (sistema_id, entorno_id));
CREATE TABLE sistema_entrada ( sistema_id INT REFERENCES saac_sistema(id) ON DELETE CASCADE, entrada_id INT REFERENCES tipo_entrada(id) ON DELETE CASCADE, PRIMARY KEY (sistema_id, entrada_id));
CREATE TABLE sistema_idioma ( sistema_id INT REFERENCES saac_sistema(id) ON DELETE CASCADE, idioma_id INT REFERENCES idioma(id) ON DELETE CASCADE, PRIMARY KEY (sistema_id, idioma_id));
CREATE TABLE sistema_plataforma ( sistema_id INT REFERENCES saac_sistema(id) ON DELETE CASCADE, plataforma_id INT REFERENCES plataforma(id) ON DELETE CASCADE, PRIMARY KEY (sistema_id, plataforma_id));
CREATE TABLE sistema_metodo ( sistema_id INT REFERENCES saac_sistema(id) ON DELETE CASCADE, metodo_id INT REFERENCES metodo_comunicacion(id) ON DELETE CASCADE, PRIMARY KEY (sistema_id, metodo_id));

-- 7. RELACIONES DE ENTRADA (Corregidas para iPad, Tablet Android y Ordenador Portátil)
INSERT INTO sistema_entrada (sistema_id, entrada_id)
SELECT id, (SELECT id FROM tipo_entrada WHERE nombre = 'manos') FROM saac_sistema 
WHERE nombre IN ('Panel pictogramas', 'Panel alfabético', 'SpeakBook', 'Puntero Láser', 'Proloquo2Go', 'Grid 3', 'Verbo', 'Boardmaker 7', 'QuickTalker 23', 'LetMeTalk', 'TD Snap', 'Guantes antiincrustantes', 'Lápiz táctil', 'Ratón Bluetooth', 'Predictable', 'VirtualTEC', 'Ease Touch', 'iPad', 'Tablet Android', 'Ordenador Portátil', 'Enchufe Inteligente WiFi');

INSERT INTO sistema_entrada (sistema_id, entrada_id)
SELECT id, (SELECT id FROM tipo_entrada WHERE nombre = 'ojos') FROM saac_sistema 
WHERE nombre IN ('Look to Speak', 'Eye tracker', 'Tablero ETRAN', 'Tallk', 'Look to learn', 'Grid 3', 'ComuniQa (TD Snap)', 'ComuniQa (Grid 3)', 'TD Pilot', 'Communicator 5', 'MegaBEE', 'OptiKey', 'Ordenador Portátil', 'SpeakBook','Panel pictogramas','Panel alfabético');

-- 8. RELACIONES DE IDIOMA
INSERT INTO sistema_idioma (sistema_id, idioma_id)
SELECT s.id, (SELECT id FROM idioma WHERE nombre = 'español') FROM saac_sistema s;

-- 9. RELACIONES DE PLATAFORMA
INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, (SELECT id FROM plataforma WHERE nombre = 'Panel físico/Papel') FROM saac_sistema 
WHERE nombre IN ('Panel pictogramas', 'Panel alfabético', 'SpeakBook', 'Puntero Láser', 'Tablero ETRAN', 'QuickTalker 23', 'ComuniQa (TD Snap)', 'ComuniQa (Grid 3)', 'Soporte de anclaje articulado', 'Conmutador de pedal', 'Conmutador Spec Amarillo', 'BJOY Chin Plus', 'MegaBEE', 'Ratón Bluetooth');

INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, (SELECT id FROM plataforma WHERE nombre = 'Windows') FROM saac_sistema 
WHERE nombre IN ('Grid 3', 'Eye tracker', 'Verbo', 'Look to learn', 'TD Snap', 'Communicator 5', 'Boardmaker 7', 'OptiKey', 'Ordenador Portátil');

INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, (SELECT id FROM plataforma WHERE nombre = 'Android') FROM saac_sistema 
WHERE nombre IN ('Look to Speak', 'Tallk', 'LetMeTalk', 'Guantes antiincrustantes', 'Lápiz táctil', 'VirtualTEC', 'EVA Facial Mouse', 'Ease Touch', 'Tablet Android', 'Enchufe Inteligente WiFi');

INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, (SELECT id FROM plataforma WHERE nombre = 'iOS') FROM saac_sistema 
WHERE nombre IN ('Proloquo2Go', 'TD Snap', 'TD Pilot', 'LetMeTalk', 'Guantes antiincrustantes', 'Lápiz táctil', 'Predictable', 'iPad', 'Enchufe Inteligente WiFi');

-- RELACIONES DE MÉTODO
INSERT INTO sistema_metodo (sistema_id, metodo_id)
SELECT id, (SELECT id FROM metodo_comunicacion WHERE nombre = 'alfabeto') FROM saac_sistema 
WHERE nombre IN ('Panel alfabético', 'Predictable', 'OptiKey', 'Communicator 5', 'MegaBEE', 'Asistente de voz AAC', 'Grid 3', 'Verbo', 'Speak4Me', 'Look to Speak');

INSERT INTO sistema_metodo (sistema_id, metodo_id)
SELECT id, (SELECT id FROM metodo_comunicacion WHERE nombre = 'pictogramas') FROM saac_sistema 
WHERE nombre IN ('Panel pictogramas', 'SpeakBook', 'TD Snap', 'LetMeTalk', 'Proloquo2Go', 'QuickTalker 23', 'Grid 3', 'Verbo', 'Boardmaker 7', 'VirtualTEC', 'Tallk');

-- RELACIONES DE ENTORNO
INSERT INTO sistema_entorno (sistema_id, entorno_id) SELECT id, 1 FROM saac_sistema;
INSERT INTO sistema_entorno (sistema_id, entorno_id)
SELECT id, 2 FROM saac_sistema 
WHERE nombre IN ('Panel pictogramas', 'Panel alfabético', 'SpeakBook', 'Tablero ETRAN', 'QuickTalker 23', 'iPad', 'Tablet Android', 'Look to Speak', 'Tallk', 'Predictable', 'VirtualTEC');

-- 10. TABLA HISTORIAL
CREATE TABLE historial_recomendacion (
    id SERIAL PRIMARY KEY,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    nombre_paciente VARCHAR(100),
    input_usuario JSONB, 
    sistemas_recomendados TEXT,
    feedback JSON
);

-- DELETE FROM historial_recomendacion WHERE id = 1;