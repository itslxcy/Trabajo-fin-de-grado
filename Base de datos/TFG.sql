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
('manos'), ('ojos'), ('cabeza'), ('voz'), ('pulsador'), ('cerebro');

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
    requiere_financiacion BOOLEAN DEFAULT FALSE,
    requiere_interlocutor BOOLEAN,
    tiempo_entrenamiento SMALLINT, 
    fatiga_fisica SMALLINT,
    velocidad SMALLINT,
    robustez SMALLINT, 
    escalabilidad SMALLINT,
    portable BOOLEAN, 
    admite_anclaje BOOLEAN,
    es_accesorio BOOLEAN DEFAULT FALSE
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

-- 6. CARGA DE SISTEMAS (Actualizado según Propuesta 2026)
INSERT INTO saac_sistema 
(nombre, descripcion, coste_min, requiere_financiacion, requiere_interlocutor, tiempo_entrenamiento, fatiga_fisica, velocidad, robustez, escalabilidad, portable, admite_anclaje, es_accesorio)
VALUES
('Panel pictogramas','Tablero físico que utiliza símbolos pictográficos (ARASAAC) para representar conceptos, acciones o necesidades básicas.',0,false,true,1,1,1,3,2,true,true, false),
('Panel alfabético','Tablero de comunicación directa mediante el deletreo, diseñado para usuarios con lectoescritura preservada que requieren una alternativa rápida a la voz.',0,false,true,1,1,1,3,2,true,true, false),
('SpeakBook','Cuaderno de comunicación diseñado para la selección mediante la mirada o puntero, facilitando la interacción en entornos donde no es posible usar tecnología (ej: ducha).',0,false,true,1,1,1,3,2,true,true, false),
('MegaBEE','Dispositivo de baja tecnología con pantalla que permite escribir mensajes con la mirada.',770,false,true,2,3,2,2,1,true,true, false),
('Look to Speak','Aplicación que utiliza la cámara frontal para permitir al usuario seleccionar frases preestablecidas mediante movimientos oculares.',0,false,false,2,3,2,2,2,true,true, false),
('Tallk','Herramienta que utiliza algoritmos de seguimiento ocular a través de la cámara de la tablet.',0,false,false,2,3,2,1,1,true,true, false),
('Grid 3','Software integral que permite desde el uso de pictogramas hasta el control del entorno y acceso a redes sociales.',300,false,false,2,2,3,2,3,true,true, false),
('Verbo','Software de comunicación dinámico que permite crear tableros personalizados con salida de voz.',40,false,false,2,2,3,2,3,true,true, false),
('Proloquo2Go','Aplicación de comunicación simbólica basada en el lenguaje natural, altamente personalizable.',300,false,false,2,2,3,3,3,true,true, false),
('TD Snap','Software centrado en símbolos y alfabetización, diseñado para una navegación rápida y eficiente.',60,false,false,2,2,3,3,3,true,true, false),
('Look to learn','Software diseñado para el entrenamiento y aprendizaje del control ocular como paso previo a la comunicación avanzada.',520,false,true,1,3,2,2,1,true,true, false),
('Tablero ETRAN','Panel transparente que permite la comunicación mediante la dirección de la mirada, donde el interlocutor descodifica el mensaje frente al usuario.',90,false,true,1,3,1,3,1,true,true, false),
('Asistente de voz AAC','Aplicación que convierte voz a texto.',0,false,false,1,1,3,2,2,true,false, false),
('Speak4Me','App que permite guardar frases usadas habitualmente para reproducirlas con rapidez.',0,false,false,1,1,2,3,1,true,false, false),
('Voice Access','Herramienta de Google que te permite controlar todo tu teléfono (abrir apps, hacer scroll, escribir) usando solo comandos de voz.',0,false,false,2,1,3,1,2,true,false, false),
('Speech to Text','Sistema de dictado y conversión de voz a texto.',0,false,false,1,1,3,1,2,true,false, false),
('ComuniQa','Pack completo con tablet configurada y los programas necesarios para que el usuario empiece a comunicarse directamente.',4000, true, false, 2,2,3,3,3,true,true, false),
('Cboard','Comunicador pictográfico basado en web que ofrece soporte en la nube y síntesis de voz sin coste para el usuario.',0,false,false,1,1,2,2,3,true,false, false),
('Picto4Me','Página web para diseñar tus propios tableros para imprimirlos o utilizarlos digitalmente.',0,false,false,2,1,2,2,3,true,false, false),
('LetMeTalk Web','Comunicador web por pictogramas',0,false,false,1,1,2,2,3,true,false, false),
('TouchChat','Herramienta que combina símbolos y texto, con opciones de predicción de palabras para agilizar la generación de mensajes.',150,false,false, 2,2,3,3,3,true,true, false),
--PERIFÉRICOS
('Eye tracker','Cámara que se conecta al ordenador y convierte el movimiento de los ojos en el puntero del ratón.',260,true,false,3,3,3,2,3,false,true, true),
('Puntero Láser','Dispositivo de apoyo manual o adaptado para la señalización directa sobre tableros de comunicación física.',99,false,true,1,3,1,3,0,true,false, true),
('Gafas con Puntero Láser', 'Soporte de puntero láser en montura oftálmica para facilitar el acceso mediante control cefálico a usuarios con movilidad reducida en extremidades (ELA Andalucía).', 120, false, true, 1, 2, 1, 3, 0, true, false, true),
('Soporte de anclaje articulado', 'Brazo mecánico ajustable para la fijación de dispositivos (tablets o eye tracker) a sillas de ruedas, garantizando la estabilidad necesaria para el seguimiento ocular o el acceso táctil.', 250, true, false, 1, 0, 3, 3, 3, false, true, true),
-- BANCOS DE VOZ
('ModelTalker Gen3', 'Sistema de síntesis de voz personalizada que requiere una extensa grabación previa de frases para clonar la voz del usuario.', 0, false, false, 3, 2, 3, 3, 3, true, false, true),
('MyOwnVoice (Acapela)', 'Servicio basado en Deep Learning que permite crear una voz digital idéntica a la original con una muestra de audio mínima de menos de 30 minutos.', 0, false, false, 3, 2, 3, 3, 3, true, false, true),
('VocaliD', 'Hibridación de voz (donada + usuario) para mayor naturalidad.', 0, false, false, 3, 2, 3, 3, 3, true, false, true),
('Bank Your Voice', 'Iniciativa española de preservación para sintetizadores abiertos.', 0, false, false, 3, 2, 3, 3, 3, true, false, true),
('Praat / Voice Analyst', 'Herramientas de análisis acústico utilizadas en logopedia para la monitorización de la fatiga vocal y la detección temprana de afectación bulbar.', 0, false, false, 2, 1, 3, 3, 2, true, false, true);

-- 7. REQUISITOS FUNCIONALES
-- Categorías generales
INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_cognitivo_min, nivel_tecnologico_min, nivel_habla_min)
SELECT id, 1, 0, 1, 0, 0 FROM saac_sistema WHERE nombre IN ('Panel pictogramas', 'Panel alfabético', 'SpeakBook', 'Tablero ETRAN', 'Puntero Láser', 'Gafas con Puntero Láser');

INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_cognitivo_min, nivel_tecnologico_min, nivel_habla_min)
SELECT id, 3, 1, 2, 3, 0 FROM saac_sistema WHERE nombre IN ('Eye tracker', 'Tallk', 'Look to Speak', 'MegaBEE', 'Look to learn');

INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_cognitivo_min, nivel_tecnologico_min, nivel_habla_min)
SELECT id, 2, 2, 3, 3, 0 FROM saac_sistema WHERE nombre IN ('Grid 3', 'Verbo', 'TD Snap', 'ComuniQa');

INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_cognitivo_min, nivel_tecnologico_min, nivel_habla_min)
SELECT id, 0, 3, 2, 2, 3 FROM saac_sistema WHERE nombre IN ('Voice Access', 'Speech to Text');

-- Voice Banking: Requiere Habla 3 para asegurar inteligibilidad óptima antes del deterioro bulbar
INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_cognitivo_min, nivel_tecnologico_min, nivel_habla_min)
SELECT id, 0, 0, 2, 3, 3 FROM saac_sistema 
WHERE nombre IN ('ModelTalker Gen3', 'MyOwnVoice (Acapela)', 'VocaliD', 'Bank Your Voice');

-- Análisis acústico preventivo
INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_cognitivo_min, nivel_tecnologico_min, nivel_habla_min)
SELECT id, 1, 0, 2, 2, 2 FROM saac_sistema WHERE nombre = 'Praat / Voice Analyst';

-- Brazo articulado
INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_cognitivo_min, nivel_tecnologico_min, nivel_habla_min)
SELECT id, 0, 0, 0, 0, 0 FROM saac_sistema WHERE nombre = 'Soporte de anclaje articulado';

INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_cognitivo_min, nivel_tecnologico_min, nivel_habla_min)
SELECT id, 2, 2, 2, 2, 0 FROM saac_sistema 
WHERE id NOT IN (SELECT sistema_id FROM sistema_requisito_funcional);

-- 8. RELACIONES DE ENTRADA
INSERT INTO sistema_entrada (sistema_id, entrada_id)
SELECT id, 4 FROM saac_sistema WHERE nombre IN ('Voice Access', 'Speech to Text', 'ModelTalker Gen3', 'MyOwnVoice (Acapela)', 'VocaliD', 'Bank Your Voice', 'Praat / Voice Analyst');

INSERT INTO sistema_entrada (sistema_id, entrada_id)
SELECT id, 1 FROM saac_sistema WHERE nombre IN ('Panel pictogramas', 'Panel alfabético', 'SpeakBook', 'Puntero Láser', 'Asistente de voz AAC', 'Proloquo2Go', 'Speak4Me', 'Grid 3', 'Verbo', 'Cboard', 'Picto4Me', 'LetMeTalk Web', 'TouchChat', 'TD Snap');

INSERT INTO sistema_entrada (sistema_id, entrada_id)
SELECT id, 2 FROM saac_sistema WHERE nombre IN ('MegaBEE', 'Look to Speak', 'Eye tracker', 'Tablero ETRAN', 'Tallk', 'Look to learn', 'Grid 3');

INSERT INTO sistema_entrada (sistema_id, entrada_id)
SELECT id, 3 FROM saac_sistema WHERE nombre IN ('Gafas con Puntero Láser', 'SpeakBook');

-- 9. RELACIONES DE IDIOMA (Soporte Español)
INSERT INTO sistema_idioma (sistema_id, idioma_id)
SELECT s.id, i.id FROM saac_sistema s, idioma i 
WHERE s.nombre IN ('Panel pictogramas', 'Panel alfabético', 'SpeakBook', 'Tablero ETRAN', 'Puntero Láser', 'Gafas con Puntero Láser', 'MegaBEE', 'Cboard', 'Picto4Me', 'LetMeTalk Web', 'ModelTalker Gen3', 'MyOwnVoice (Acapela)', 'VocaliD', 'Bank Your Voice', 'Praat / Voice Analyst');

INSERT INTO sistema_idioma (sistema_id, idioma_id)
SELECT s.id, i.id FROM saac_sistema s, idioma i 
WHERE s.nombre IN ('Grid 3', 'Verbo', 'TD Snap', 'ComuniQa') AND i.nombre IN ('catalán', 'gallego', 'euskera');

INSERT INTO sistema_idioma (sistema_id, idioma_id)
SELECT s.id, (SELECT id FROM idioma WHERE nombre = 'español') FROM saac_sistema s ON CONFLICT DO NOTHING;

-- 10. RELACIONES DE PLATAFORMA
INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, 4 FROM saac_sistema WHERE nombre IN ('Panel pictogramas', 'Panel alfabético', 'SpeakBook', 'Puntero Láser', 'Gafas con Puntero Láser', 'MegaBEE', 'Tablero ETRAN', 'ComuniQa', 'Soporte de anclaje articulado');

INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, 1 FROM saac_sistema WHERE nombre IN ('Grid 3', 'Eye tracker', 'Verbo', 'Look to learn', 'TD Snap', 'ModelTalker Gen3');

INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, 3 FROM saac_sistema WHERE nombre IN ('Look to Speak', 'Tallk', 'Voice Access', 'Speech to Text', 'Asistente de voz AAC', 'Speak4Me', 'Verbo');

INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, 2 FROM saac_sistema WHERE nombre IN ('Proloquo2Go', 'TD Snap', 'Speak4Me', 'TouchChat');

INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, 5 FROM saac_sistema 
WHERE nombre IN ('Cboard','Picto4Me','LetMeTalk Web', 'MyOwnVoice (Acapela)', 'VocaliD', 'Bank Your Voice', 'Praat / Voice Analyst');
