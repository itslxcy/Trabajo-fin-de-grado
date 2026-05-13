-- 1. CONFIGURACIÓN INICIAL
SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

-- 2. LIMPIEZA (Opcional: borra datos previos si los hubiera para evitar duplicados)
-- TRUNCATE public.sistema_metodo, public.sistema_plataforma, public.sistema_idioma, public.sistema_entrada, public.sistema_entorno, public.sistema_dependencia, public.sistema_requisito_funcional CASCADE;

-- 3. INSERCIÓN DE DATOS MAESTROS
-- Idiomas
INSERT INTO public.idioma (id, nombre) VALUES 
(1, 'español'), (2, 'gallego'), (3, 'catalán'), (4, 'euskera')
ON CONFLICT (id) DO NOTHING;

-- Plataformas
INSERT INTO public.plataforma (id, nombre) VALUES 
(1, 'Windows'), (2, 'iOS'), (3, 'Android'), (4, 'Panel físico/Papel'), (5, 'Web')
ON CONFLICT (id) DO NOTHING;

-- Entornos
INSERT INTO public.entorno_uso (id, nombre) VALUES 
(1, 'domicilio'), (2, 'exterior')
ON CONFLICT (id) DO NOTHING;

-- Tipos de Entrada (Métodos de interacción)
INSERT INTO public.tipo_entrada (id, nombre) VALUES 
(1, 'manos'), (2, 'ojos'), (3, 'cabeza'), (4, 'voz'), (5, 'pulsador')
ON CONFLICT (id) DO NOTHING;

-- Métodos de Comunicación (Pictos/Alfabeto)
INSERT INTO public.metodo_comunicacion (id, nombre) VALUES 
(1, 'alfabeto'), (2, 'pictogramas')
ON CONFLICT (id) DO NOTHING;

-- 4. INSERCIÓN DE SISTEMAS Y HARDWARE (Tabla saac_sistema) - SIN requiere_hardware_extra NI coste_min
INSERT INTO public.saac_sistema (id, nombre, descripcion, requiere_interlocutor, fatiga_fisica, portable, admite_anclaje, enlace_info, categoria) VALUES
(1, 'Panel pictogramas', 'Tablero físico que utiliza símbolos pictográficos (ARASAAC).', true, 0, true, true, 'https://arasaac.org/', 'sistema'),
(2, 'Panel alfabético', 'Tablero de comunicación directa mediante el deletreo.', true, 0, true, true, 'https://downloads.tobiidynavox.com/Conditions/ALS/Communication_Board/TD_CommunicationBoard_ALS_es-ES.pdf', 'sistema'),
(3, 'SpeakBook', 'Cuaderno de comunicación diseñado para la selección mediante la mirada.', true, 0, true, true, 'https://aulaabierta.arasaac.org/materiales-caa-tableros-de-comunicacion', 'sistema'),
(4, 'Tablero ETRAN', 'Panel transparente para comunicación mediante la dirección de la mirada.', true, 0, true, true, 'https://downloads.tobiidynavox.com/Conditions/ALS/Communication_Board/TD_CommunicationBoard_ALS_es-ES.pdf', 'sistema'),
(5, 'QuickTalker 23', 'Comunicador portátil con 23 casillas para mensajes grabados.', false, 0, true, false, 'https://qinera.com/es/tienda/comunicadores-sencillos/quick-talker-23', 'sistema'),
(6, 'MegaBEE', 'Escritura asistida por mirada y teclado táctil asistido por un interlocutor.', true, 0, true, true, 'https://www.e2l.uk.com/megabee/indexes.html', 'sistema'),
(7, 'Look to Speak', 'Mirada a través de cámara frontal para frases preestablecidas.', false, 1, true, true, 'https://play.google.com/store/apps/details?id=com.androidexperiments.looktospeak', 'sistema'),
(8, 'Tallk', 'Seguimiento ocular a través de la cámara de la tablet (Samsung).', false, 1, true, true, 'https://play.google.com/store/apps/details?id=com.irisbond.tallk', 'sistema'),
(9, 'Grid 3', 'Software integral para comunicación y control del entorno.', false, 1, true, true, 'https://qinera.com/es/tienda/software-para-la-comunicacion/grid-3', 'sistema'),
(10, 'Verbo', 'Software de comunicación dinámico con salida de voz.', false, 1, true, true, 'https://api.eneso.es/verbo', 'sistema'),
(11, 'Proloquo2Go', 'Comunicación simbólica para iOS basada en lenguaje natural.', false, 2, true, true, 'https://www.assistiveware.com/es/productos/proloquo2go', 'sistema'),
(12, 'TD Snap', 'Software centrado en símbolos y navegación rápida.', false, 1, true, true, 'https://apps.apple.com/es/app/td-snap/id1072799231', 'sistema'),
(13, 'Communicator 5', 'Software de comunicación eficiente para texto y símbolos.', false, 1, true, true, 'https://qinera.com/es/tienda/software-para-la-comunicacion/communicator-5', 'sistema'),
(14, 'Boardmaker 7', 'Estándar para crear materiales basados en símbolos.', true, 2, true, true, 'https://qinera.com/es/tienda/software-para-la-comunicacion/boardmaker-7', 'sistema'),
(15, 'Look to learn', 'Software de entrenamiento para el control ocular.', true, 1, true, true, 'https://qinera.com/es/tienda/software-para-la-comunicacion/look-to-learn-1-licencia-electronica', 'sistema'),
(16, 'LetMeTalk', 'App de comunicación mediante pictogramas gratuita.', false, 2, true, false, 'https://apps.apple.com/us/app/letmetalk-talker-saac-caa-sac/id919990138', 'sistema'),
(17, 'OptiKey', 'Teclado en pantalla gratuito optimizado para control ocular y Windows.', false, 1, true, true, 'https://www.optikey.org/', 'sistema'),
(18, 'Predictable', 'App de comunicación alfabética con predicción inteligente y acceso por pulsador.', false, 2, true, true, 'https://apps.apple.com/es/app/predictable/id404445007', 'sistema'),
(19, 'VirtualTEC', 'Comunicador personalizable para Android con acceso por pulsador.', false, 2, true, true, 'https://play.google.com/store/apps/details?id=com.uvigo.gti.VirtualTEC', 'sistema'),
(20, 'EVA Facial Mouse', 'Control del dispositivo Android mediante movimientos de la cabeza.', false, 2, true, true, 'https://easeapps.xyz/es/eva/', 'sistema'),
(21, 'Ease Touch', 'Facilita el uso de pantallas táctiles mediante pulsaciones simples o esperas.', false, 3, true, false, 'https://easeapps.xyz/es/ease-touch/', 'sistema'),
(22, 'Voice Access', 'App para controlar el móvil mediante la voz', false, 0, true, true, 'https://play.google.com/store/apps/details?id=com.google.android.apps.accessibility.voiceaccess&hl=es', 'sistema'),
(23, 'Asistente de voz AAC', 'Conversión de texto a voz.', false, 1, true, false, 'https://play.google.com/store/apps/details?id=nl.asoft.speechassistant', 'sistema'),
(24, 'Speak4Me', 'App para reproducir frases rápidas guardadas.', false, 1, true, false, 'https://apps.apple.com/es/app/speak4me-convertir-texto-a-voz/id894460403', 'sistema'),
(25, 'ComuniQa (TD Snap)', 'Pack tablet + seguimiento ocular + TD Snap.', false, 1, true, true, 'https://qinera.com/es/tienda/comunicadores-de-mirada/comuniqa-eye-con-td-snap', 'sistema'),
(26, 'ComuniQa (Grid 3)', 'Pack tablet + seguimiento ocular + Grid 3.', false, 1, true, true, 'https://qinera.com/es/tienda/comunicadores-de-mirada/comuniqa-eye-con-grid-3', 'sistema'),
(27, 'TD Pilot', 'Comunicador ocular de alta gama integrado para iPad.', false, 1, true, true, 'https://qinera.com/es/tienda/comunicadores-de-mirada/TD-Pilot', 'sistema'),
(28, 'Amazon Alexa / Google Home', 'Asistente virtual para control doméstico.', false, 1, false, false, 'https://www.amazon.es/b?node=15712533031', 'sistema'),
(29, 'Enchufe Inteligente WiFi', 'Permite encender y apagar lámparas.', false, 0, false, false, NULL, 'hardware'),
(30, 'iPad', 'Tablet recomendada para iOS.', false, 0, true, true, 'https://www.apple.com/es/ipad/', 'hardware'),
(31, 'Tablet Android', 'Dispositivo versátil para Android.', false, 0, true, true, NULL, 'hardware'),
(32, 'Ordenador Portátil', 'Necesario para software avanzado.', false, 0, true, true, NULL, 'hardware'),
(33, 'Eye tracker', 'Lector ocular para control de dispositivos.', false, 1, false, true, 'https://www.irisbond.com/', 'hardware'),
(34, 'Puntero Láser', 'Señalización directa para tableros físicos.', true, 0, true, false, NULL, 'hardware'),
(35, 'Gafas con Puntero Láser', 'Puntero láser adaptado para control cefálico.', true, 1, true, false, 'https://www.elaandalucia.es/gafas-puntero-laser-todas-las-unidades-hospitalarias-ela-andalucia/', 'hardware'),
(36, 'Soporte de anclaje articulado', 'Brazo mecánico para fijación.', false, 0, false, true, 'https://qinera.com/es/tienda/comunicacion-aumentativa/soportes-y-brazos-caa', 'hardware'),
(37, 'Conmutador por soplido (Pufo)', 'Sensor de soplido.', false, 0, true, true, 'https://qinera.com/es/tienda/acceso-a-dispositivos-y-conmutadores/quha-pufo-con-kit-de-montaje-de-cabeza', 'hardware'),
(38, 'Conmutador de pedal', 'Pulsador para ser activado con el pie.', false, 1, true, false, 'https://qinera.com/es/tienda/ratones-y-pulsadores/conmutador-de-pedal', 'hardware'),
(39, 'Conmutador Spec Amarillo', 'Pulsador de fácil activación física.', false, 1, true, true, 'http://qinera.com/es/tienda/conmutadores/conmutador-spec-amarillo', 'hardware'),
(40, 'BJOY Chin Plus', 'Joystick de barbilla de alta precisión.', false, 1, true, true, 'https://qinera.com/es/tienda/ratones-y-pulsadores/bjoy-chin-plus', 'hardware'),
(41, 'Guantes antiincrustantes', 'Guante para evitar toques accidentales.', false, 0, true, false, 'https://www.amazon.es/HUION-Tableta-Antiincrustante-Personas-Tabletas/dp/B00VTHAS00', 'hardware'),
(42, 'Lápiz táctil', 'Ergonómico para mayor precisión.', false, 1, true, false, 'https://goo.su/jnGcNM', 'hardware'),
(43, 'Ratón Bluetooth', 'Ratón inalámbrico ergonómico.', false, 1, true, true, 'https://goo.su/3XvwDat', 'hardware'),
(44, 'ModelTalker Gen3', 'Síntesis de voz personalizada.', false, 2, true, false, 'https://modeltalker.org/', 'servicio'),
(45, 'MyOwnVoice (Acapela)', 'Voz digital idéntica.', false, 1, true, false, 'https://mov.acapela-group.com/es/home-es/', 'servicio'),
(46, 'VocaliD', 'Hibridación de voz personalizada.', false, 1, true, false, 'https://vocalid.ai/', 'servicio')
ON CONFLICT (id) DO UPDATE SET nombre = EXCLUDED.nombre; 

-- 5. REQUISITOS FUNCIONALES
INSERT INTO public.sistema_requisito_funcional (sistema_id, nivel_visual_min, nivel_auditivo_min, nivel_tecnologico_min, nivel_habla_min) VALUES
(1,2,0,0,0),(2,2,0,0,0),(3,2,0,0,0),(4,2,0,0,0),(5,1,1,2,0),(6,2,0,1,0),
(7,2,1,1,0),(8,2,1,1,0),(9,2,2,2,0),(10,2,2,2,0),(11,2,1,2,0),(12,2,2,2,0),
(13,2,2,2,0),(14,1,1,2,0),(15,2,1,1,0),(16,2,1,2,0),(17,2,1,1,0),(18,2,2,2,0),
(19,1,1,2,0),(20,2,2,2,0),(21,1,1,2,0),(22,2,1,2,3),(23,2,1,1,0),(24,2,1,2,0),
(25,2,2,2,0),(26,2,2,2,0),(27,2,2,2,0),(28,1,1,2,3),(29,2,2,2,0),(30,1,1,1,0),
(31,1,1,1,0),(32,1,1,1,0),(33,2,1,1,0),(34,2,1,0,0),(35,2,1,0,0),(36,0,0,0,0),
(37,1,1,1,0),(38,1,1,0,0),(39,1,1,0,0),(40,1,1,1,0),(41,1,1,0,0),(42,1,1,0,0),
(43,1,1,1,0),(44,0,1,2,3),(45,0,1,2,3),(46,0,1,2,3)
ON CONFLICT (sistema_id) DO NOTHING;

-- 6. RELACIONES (PLATAFORMAS, IDIOMAS, MÉTODOS)
-- Solo un ejemplo para no saturar, pero el formato es este:
INSERT INTO public.sistema_plataforma (sistema_id, plataforma_id) VALUES 
(1,4),(2,4),(3,4),(4,4),(5,4),(9,1),(10,1),(11,2),(12,2),(16,3),(19,3),(22,3)
ON CONFLICT DO NOTHING;

INSERT INTO public.sistema_idioma (sistema_id, idioma_id) VALUES 
(1,1),(2,1),(3,1),(4,1),(5,1),(1,2),(1,3),(1,4)
ON CONFLICT DO NOTHING;

-- REAJUSTE DE SECUENCIAS
SELECT setval('public.idioma_id_seq', (SELECT max(id) FROM public.idioma));
SELECT setval('public.saac_sistema_id_seq', (SELECT max(id) FROM public.saac_sistema));
