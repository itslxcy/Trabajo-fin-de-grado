-- 1. LIMPIEZA TOTAL DE TABLAS
DROP TABLE IF EXISTS paciente_entrada CASCADE;
DROP TABLE IF EXISTS sistema_entrada CASCADE;
DROP TABLE IF EXISTS sistema_idioma CASCADE;
DROP TABLE IF EXISTS sistema_plataforma CASCADE;
DROP TABLE IF EXISTS sistema_entorno CASCADE;
DROP TABLE IF EXISTS sistema_requisito_funcional CASCADE;
DROP TABLE IF EXISTS paciente CASCADE;
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
('español'), ('inglés'), ('francés'), ('portugués'), ('gallego'), ('catalán'), ('euskera');

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

-- 4. TABLA DE REQUISITOS
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

-- 6. CARGA DE SISTEMAS (Incluyendo Gafas con Puntero)
INSERT INTO saac_sistema
(nombre, descripcion, coste_min, requiere_financiacion, requiere_interlocutor, tiempo_entrenamiento, fatiga_fisica, velocidad, robustez, escalabilidad, portable, admite_anclaje, es_accesorio)
VALUES
('Panel pictogramas','Tablero físico con símbolos ARASAAC',0,false,true,1,1,1,3,2,true,true, false),
('Panel alfabético','Tablero físico con letras y frases comunes',0,false,true,1,1,1,3,2,true,true, false),
('SpeakBook','Cuaderno de comunicación para mirada o puntero',0,false,true,1,1,1,3,2,true,true, false),
('Puntero Láser','Accesorio manual para señalar tableros',99,false,true,1,3,1,3,0,true,false, true),
('Gafas con Puntero Láser', 'Montura para control cefálico (Ref: ELA Andalucía)', 120, false, true, 1, 2, 1, 3, 0, true, false, true),
('MegaBEE','Comunicador por mirada de baja tecnología',770,false,true,2,3,2,2,1,true,true, false),
('Look to Speak','App de mirada de Google para Android',0,false,false,2,3,2,2,2,true,true, false),
('Tallk','App de mirada Samsung para tablets',0,false,false,2,3,2,1,1,true,true, false),
('Grid 3','Software de comunicación avanzado (Windows)',300,false,false,2,2,3,2,3,true,true, false),
('Verbo','Software de comunicación con plantillas (Windows/Android)',40,false,false,2,2,3,2,3,true,true, false),
('Eye tracker','Hardware periférico de seguimiento ocular',260,true,false,3,3,3,2,3,false,true, true),
('Proloquo2Go','App de comunicación basada en pictogramas (iOS)',300,false,false,2,2,3,3,3,true,true, false),
('TD Snap','Software de Tobii Dynavox (Windows/iOS)',60,false,false,2,2,3,3,3,true,true, false),
('Look to learn','Software para aprender a usar la mirada',520,false,true,1,3,2,2,1,true,true, false),
('Tablero ETRAN','Panel transparente para comunicación por mirada',90,false,true,1,3,1,3,1,true,true, false),
('Asistente de voz AAC','App simple de síntesis de voz',0,false,false,1,1,3,2,2,true,false, false),
('Speak4Me','Conversor de texto a voz funcional',0,false,false,1,1,2,3,1,true,false, false),
('Voice Access','Control del dispositivo mediante la voz',0,false,false,2,1,3,1,2,true,false, false),
('Speech to Text','Dictado y conversión de voz a texto',0,false,false,1,1,3,1,2,true,false, false),
('ComuniQa','Solución integral con tablet y software',4000, true, false, 2,2,3,3,3,true,true, false),
('Cboard','Comunicador pictográfico web gratuito',0,false,false,1,1,2,2,3,true,false, false),
('Picto4Me','Editor web de tableros',0,false,false,2,1,2,2,3,true,false, false),
('LetMeTalk Web','Comunicador web por pictogramas',0,false,false,1,1,2,2,3,true,false, false),
('TouchChat','App de comunicación avanzada con símbolos',150,false,false, 2,2,3,3,3,true,true, false);

-- 7. REQUISITOS FUNCIONALES
-- Baja tecnología y Punteros
INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_cognitivo_min, nivel_tecnologico_min, nivel_habla_min)
SELECT id, 1, 0, 1, 0, 0 FROM saac_sistema WHERE nombre IN ('Panel pictogramas', 'Panel alfabético', 'SpeakBook', 'Tablero ETRAN', 'Puntero Láser', 'Gafas con Puntero Láser');

-- Mirada Alta Tecnología
INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_cognitivo_min, nivel_tecnologico_min, nivel_habla_min)
SELECT id, 3, 1, 2, 3, 0 FROM saac_sistema WHERE nombre IN ('Eye tracker', 'Tallk', 'Look to Speak', 'MegaBEE', 'Look to learn');

-- Software complejo
INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_cognitivo_min, nivel_tecnologico_min, nivel_habla_min)
SELECT id, 2, 2, 3, 3, 0 FROM saac_sistema WHERE nombre IN ('Grid 3', 'Verbo', 'TD Snap', 'ComuniQa');

-- Apps de Voz
INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_cognitivo_min, nivel_tecnologico_min, nivel_habla_min)
SELECT id, 0, 3, 2, 2, 3 FROM saac_sistema WHERE nombre IN ('Voice Access', 'Speech to Text');

-- Resto (Asignación automática nivel medio)
INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_cognitivo_min, nivel_tecnologico_min, nivel_habla_min)
SELECT id, 2, 2, 2, 2, 0 FROM saac_sistema 
WHERE id NOT IN (SELECT sistema_id FROM sistema_requisito_funcional);

-- 8. RELACIONES DE ENTRADA
-- Entrada Manos (ID 1)
INSERT INTO sistema_entrada (sistema_id, entrada_id)
SELECT id, 1 FROM saac_sistema WHERE nombre IN (
    'Panel pictogramas', 'Panel alfabético', 'SpeakBook', 'Puntero Láser',
    'Asistente de voz AAC', 'Proloquo2Go', 'Speak4Me', 'Grid 3', 'Verbo',
    'Cboard', 'Picto4Me', 'LetMeTalk Web', 'TouchChat', 'TD Snap'
);

-- Entrada Ojos (ID 2)
INSERT INTO sistema_entrada (sistema_id, entrada_id)
SELECT id, 2 FROM saac_sistema WHERE nombre IN (
    'MegaBEE', 'Look to Speak', 'Eye tracker', 'Tablero ETRAN', 'Tallk', 'Look to learn', 'Grid 3'
);

-- Entrada Cabeza (ID 3)
INSERT INTO sistema_entrada (sistema_id, entrada_id)
SELECT id, 3 FROM saac_sistema WHERE nombre IN ('Gafas con Puntero Láser', 'SpeakBook');

-- Entrada Voz (ID 4)
INSERT INTO sistema_entrada (sistema_id, entrada_id)
SELECT id, 4 FROM saac_sistema WHERE nombre IN ('Voice Access', 'Speech to Text');

-- 9. RELACIONES DE IDIOMA
INSERT INTO sistema_idioma (sistema_id, idioma_id)
SELECT id, 1 FROM saac_sistema;

-- 10. RELACIONES DE PLATAFORMA
INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, 4 FROM saac_sistema WHERE nombre IN ('Panel pictogramas', 'Panel alfabético', 'SpeakBook', 'Puntero Láser', 'Gafas con Puntero Láser', 'MegaBEE', 'Tablero ETRAN', 'ComuniQa');

INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, 1 FROM saac_sistema WHERE nombre IN ('Grid 3', 'Eye tracker', 'Verbo', 'Look to learn', 'TD Snap');

INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, 3 FROM saac_sistema WHERE nombre IN ('Look to Speak', 'Tallk', 'Voice Access', 'Speech to Text', 'Asistente de voz AAC', 'Speak4Me', 'Verbo');

INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, 2 FROM saac_sistema WHERE nombre IN ('Proloquo2Go', 'TD Snap', 'Speak4Me', 'TouchChat');

INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, 5 FROM saac_sistema WHERE nombre IN ('Cboard','Picto4Me','LetMeTalk Web');