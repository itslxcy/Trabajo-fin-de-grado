-- 1. LIMPIEZA TOTAL
DROP TABLE IF EXISTS historial_recomendacion CASCADE;
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
CREATE TABLE tipo_entrada (id SERIAL PRIMARY KEY, nombre TEXT UNIQUE NOT NULL);
INSERT INTO tipo_entrada (nombre) VALUES ('manos'), ('ojos'), ('cabeza'), ('voz'), ('pulsador');

CREATE TABLE idioma (id SERIAL PRIMARY KEY, nombre TEXT UNIQUE NOT NULL);
INSERT INTO idioma (nombre) VALUES ('español'), ('gallego'), ('catalán'), ('euskera');

CREATE TABLE plataforma (id SERIAL PRIMARY KEY, nombre TEXT UNIQUE NOT NULL);
INSERT INTO plataforma (nombre) VALUES ('Windows'), ('iOS'), ('Android'), ('Papel / Panel físico'), ('Web');

CREATE TABLE entorno_uso (id SERIAL PRIMARY KEY, nombre TEXT UNIQUE NOT NULL);
INSERT INTO entorno_uso (nombre) VALUES ('Interior/Cama'), ('Interior/Silla'), ('Exterior/Luz Solar'), ('Exterior/Movimiento');

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

-- 4. CARGA DE DATOS
INSERT INTO saac_sistema (nombre, descripcion, requiere_interlocutor, fatiga_fisica, portable, admite_anclaje, enlace_info) VALUES
('Panel pictogramas','Tablero físico que utiliza símbolos pictográficos.',true,1,true,true, 'https://arasaac.org/'),
('Panel alfabético','Tablero de comunicación directa mediante el deletreo.',true,1,true,true, NULL),
('SpeakBook','Cuaderno diseñado para selección mediante la mirada.',true,1,true,true, NULL),
('Tablero ETRAN','Panel transparente para comunicación mediante mirada.',true,1,true,true, NULL),
('Grid 3','Software integral para comunicación y control del entorno.',false,1,true,true, 'https://qinera.com/es/tienda/software-para-la-comunicacion/grid-3'),
('Verbo','Software de comunicación dinámico con salida de voz.',false,1,true,true, NULL),
('TD Snap','Software centrado en símbolos y navegación rápida.',false,1,true,true, NULL),
('LetMeTalk','App de comunicación mediante pictogramas gratuita.',false,1,true,false, NULL),
('Predictable','App alfabética con predicción inteligente.',false,1,true,true, NULL),
('iPad','Tablet recomendada para iOS.',false,1,true,true, NULL),
('Tablet Android','Dispositivo versátil para apps Android.',false,1,true,true, NULL),
('Ordenador Portátil','Necesario para software avanzado.',false,0,true,true, NULL),
('Eye tracker','Lector ocular para control de dispositivos.',false,1,false,true, 'https://www.irisbond.com/'),
('Soporte de anclaje articulado','Brazo mecánico para fijación.',false,0,false,true, NULL);

-- 5. REQUISITOS FUNCIONALES
CREATE TABLE sistema_requisito_funcional (
    sistema_id INT PRIMARY KEY REFERENCES saac_sistema(id) ON DELETE CASCADE,
    nivel_visual_min SMALLINT DEFAULT 0,
    nivel_auditivo_min SMALLINT DEFAULT 0,
    nivel_cognitivo_min SMALLINT DEFAULT 0,
    nivel_tecnologico_min SMALLINT DEFAULT 0,
    nivel_habla_min SMALLINT DEFAULT 0
);
INSERT INTO sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_tecnologico_min)
SELECT id, 3, 2 FROM saac_sistema WHERE nombre IN ('Grid 3', 'Eye tracker', 'Tablero ETRAN');

-- 6. TABLAS DE RELACIÓN (LAS QUE FALLABAN)
CREATE TABLE sistema_entrada (sistema_id INT REFERENCES saac_sistema(id), entrada_id INT REFERENCES tipo_entrada(id), PRIMARY KEY (sistema_id, entrada_id));
CREATE TABLE sistema_plataforma (sistema_id INT REFERENCES saac_sistema(id), plataforma_id INT REFERENCES plataforma(id), PRIMARY KEY (sistema_id, plataforma_id));
CREATE TABLE sistema_idioma (sistema_id INT REFERENCES saac_sistema(id), idioma_id INT REFERENCES idioma(id), PRIMARY KEY (sistema_id, idioma_id));

-- 7. INSERTAR RELACIONES
INSERT INTO sistema_entrada (sistema_id, entrada_id)
SELECT id, (SELECT id FROM tipo_entrada WHERE nombre = 'manos') FROM saac_sistema WHERE nombre IN ('Panel pictogramas', 'Panel alfabético', 'Grid 3', 'iPad', 'Tablet Android');
INSERT INTO sistema_entrada (sistema_id, entrada_id)
SELECT id, (SELECT id FROM tipo_entrada WHERE nombre = 'ojos') FROM saac_sistema WHERE nombre IN ('Tablero ETRAN', 'Grid 3', 'Eye tracker', 'SpeakBook');

INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, (SELECT id FROM plataforma WHERE nombre = 'Papel / Panel físico') FROM saac_sistema WHERE nombre IN ('Panel pictogramas', 'Panel alfabético', 'Tablero ETRAN', 'SpeakBook');
INSERT INTO sistema_plataforma (sistema_id, plataforma_id)
SELECT id, (SELECT id FROM plataforma WHERE nombre = 'Windows') FROM saac_sistema WHERE nombre IN ('Grid 3', 'Eye tracker', 'Ordenador Portátil');

-- 10. HISTORIAL
CREATE TABLE historial_recomendacion (id SERIAL PRIMARY KEY, fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP, nombre_paciente VARCHAR(100), input_usuario JSONB, sistemas_recomendados TEXT, feedback JSON);
-- DELETE FROM historial_recomendacion WHERE id = 1;