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
    admite_anclaje BOOLEAN 
);

-- 4. TABLA DE REQUISITOS (Incluye Habla)
CREATE TABLE sistema_requisito_funcional (
    sistema_id INT PRIMARY KEY REFERENCES saac_sistema(id) ON DELETE CASCADE,
    nivel_visual_min SMALLINT DEFAULT 0,
    nivel_auditivo_min SMALLINT DEFAULT 0,
    nivel_cognitivo_min SMALLINT DEFAULT 0,
    nivel_tecnologico_min SMALLINT DEFAULT 0,
    nivel_habla_min SMALLINT DEFAULT 0
);

-- 5. TABLAS DE RELACIÓN (Muchos a Muchos)
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
(nombre, descripcion, coste_min, requiere_financiacion, requiere_interlocutor, tiempo_entrenamiento, fatiga_fisica, velocidad, robustez, escalabilidad, portable, admite_anclaje)
VALUES
('Panel pictogramas','Tablero símbolos',0,false,true,1,2,1,3,2,true,true),
('Panel alfabético','Tablero letras',0,false,true,2,2,1,3,2,true,true),
('SpeakBook','Cuaderno comunicación',0,false,true,1,1,1,3,2,true,true),
('Puntero Láser','Puntero mirada/cabeza',99,false,true,1,3,1,3,0,true,false),
('MegaBEE','Comunicador mirada',770,false,true,2,3,2,2,1,true,true),
('Look to Speak','App mirada Google',0,false,false,2,3,2,2,2,true,true),
('Tallk','App con seguimiento ocular Samsung',0,false,false,2,3,2,1,1,true,true),
('Grid 3','Software comunicación profesional',300,false,false,2,2,3,2,3,true,true),
('Verbo','Software comunicación Eneso',40,false,false,2,2,3,2,3,true,true),
('Eye tracker','Seguimiento ocular hardware',260,true,false,3,3,3,2,3,false,true),
('Proloquo2Go','App pictográfica iOS',300,false,false,2,2,3,3,3,true,true),
('TD Snap','Comunicador profesional Tobii',60,false,false,2,2,3,3,3,true,true),
('Look to learn','Software entrenamiento mirada',520,false,true,1,3,2,2,1,true,true),
('Tablero ETRAN','Panel transparente mirada',90,false,true,1,3,1,3,1,true,true),
('Asistente de voz AAC','App de texto a voz frases',0,false,false,1,1,3,2,2,true,false),
('Speak4Me','Conversor de texto a voz simple',0,false,false,1,1,2,3,1,true,false),
('Voice Access','Control del dispositivo mediante voz',0,false,false,2,1,3,1,2,true,false),
('Speech to Text','Dictado por voz y transcripción',0,false,false,1,1,3,1,2,true,false),
('ComuniQa','Solución integral hardware + software',4000, true, false, 2,2,3,3,3,true,true),
('Cboard','Comunicador pictográfico online',0,false,false,1,1,2,2,3,true,false),
('Picto4Me','Editor web de tableros con pictogramas',0,false,false,2,1,2,2,3,true,false),
('LetMeTalk Web','Comunicador basado en pictogramas',0,false,false,1,1,2,2,3,true,false),
('TouchChat','App pictográfica avanzada',150,false,false, 2,2,3,3,3,true,true);

-- 7. REQUISITOS FUNCIONALES
-- Baja tecnología (Nivel visual 1 para que aparezcan si hay poca visión)
INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_cognitivo_min, nivel_tecnologico_min, nivel_habla_min)
SELECT id, 1, 0, 1, 0, 0 FROM saac_sistema WHERE nombre IN ('Panel pictogramas', 'Panel alfabético', 'SpeakBook', 'Tablero ETRAN', 'Puntero Láser');

-- Mirada Alta Tecnología
INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_cognitivo_min, nivel_tecnologico_min, nivel_habla_min)
SELECT id, 3, 1, 2, 3, 0 FROM saac_sistema WHERE nombre IN ('Eye tracker', 'Tallk', 'Look to Speak', 'MegaBEE', 'Look to learn');

-- Software complejo
INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_cognitivo_min, nivel_tecnologico_min, nivel_habla_min)
SELECT id, 2, 2, 3, 3, 0 FROM saac_sistema WHERE nombre IN ('Grid 3', 'Verbo', 'TD Snap', 'ComuniQa');

-- Apps de Voz REQUIEREN HABLA (nivel 3)
INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_cognitivo_min, nivel_tecnologico_min, nivel_habla_min)
SELECT id, 0, 3, 2, 2, 3 FROM saac_sistema WHERE nombre IN ('Voice Access', 'Speech to Text');

-- Resto de sistemas (Asignación general)
INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_cognitivo_min, nivel_tecnologico_min, nivel_habla_min)
SELECT id, 2, 2, 2, 2, 0 FROM saac_sistema 
WHERE id NOT IN (SELECT sistema_id FROM sistema_requisito_funcional);

-- 8. RELACIONES DE ENTRADA
-- Manos (ID 1)
INSERT INTO sistema_entrada (sistema_id, entrada_id)
SELECT id, 1 FROM saac_sistema WHERE nombre IN ('Asistente de voz AAC', 'Proloquo2Go', 'Speak4Me', 'Grid 3', 'Verbo','Cboard','Picto4Me','LetMeTalk Web','TouchChat');
-- Ojos (ID 2)
INSERT INTO sistema_entrada (sistema_id, entrada_id)
SELECT id, 2 FROM saac_sistema WHERE nombre IN ('MegaBEE', 'Look to Speak', 'Eye tracker', 'Tablero ETRAN', 'Tallk', 'Look to learn');
-- Voz (ID 4)
INSERT INTO sistema_entrada (sistema_id, entrada_id)
SELECT id, 4 FROM saac_sistema WHERE nombre IN ('Voice Access', 'Speech to Text');

-- 9. RELACIONES DE IDIOMA (Todos Español ID 1)
INSERT INTO sistema_idioma (sistema_id, idioma_id)
SELECT id, 1 FROM saac_sistema;

-- 10. RELACIONES DE PLATAFORMA
-- Hardware (ID 4)
INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, 4 FROM saac_sistema WHERE nombre IN ('Panel pictogramas', 'Panel alfabético', 'SpeakBook', 'Puntero Láser', 'MegaBEE', 'Tablero ETRAN', 'ComuniQa');
-- Windows (ID 1)
INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, 1 FROM saac_sistema WHERE nombre IN ('Grid 3', 'Eye tracker', 'Verbo', 'Look to learn', 'TD Snap');
-- Android (ID 3)
INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, 3 FROM saac_sistema WHERE nombre IN ('Look to Speak', 'Tallk', 'Voice Access', 'Speech to Text', 'Asistente de voz AAC','Speak4Me');
-- iOS (ID 2)
INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, 2 FROM saac_sistema WHERE nombre IN ('Proloquo2Go', 'TD Snap', 'Speak4Me', 'TouchChat');
-- Web (ID 5)
INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, 5 FROM saac_sistema WHERE nombre IN ('Cboard','Picto4Me','LetMeTalk Web');