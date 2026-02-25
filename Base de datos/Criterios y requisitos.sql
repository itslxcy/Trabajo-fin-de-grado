-- 1 Tabla principal de Sistemas
CREATE TABLE IF NOT EXISTS public.caracteristicas_saac (
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL,
    descripcion TEXT,
    coste NUMERIC,                          -- Relación: Presupuesto
    nivel_visual_requerido TEXT,            -- Relación: Capacidad visual
    nivel_auditivo_requerido TEXT,          -- Relación: Capacidad auditiva
	carga_cognitiva_estimada TEXT,          -- Relación: Capacidad cognitiva
    complejidad_tecnologica TEXT,           -- Relación: Manejo de tecnologías
    requiere_motilidad_fina BOOLEAN,        -- Relación: Pulsaciones
    idiomas_disponibles TEXT,                 -- Relación: Idioma
    tipo_anclaje_silla TEXT,                -- Relación: Compatibilidad silla
    es_escalable BOOLEAN,                   -- Relación: Etapa enfermedad (Adaptabilidad)
    grado_portabilidad TEXT		           -- Relación: Dónde se usará
);

-- 2 Tabla de Requisitos (ej: "Capacidad cognitiva", "motilidad fina", "presupuesto")
CREATE TABLE IF NOT EXISTS public.requisitos_paciente (
    id SERIAL PRIMARY KEY,
    nombre_paciente TEXT,
    presupuesto NUMERIC,                -- Empareja con: coste
    capacidad_visual TEXT,                  -- Empareja con: nivel_visual_requerido
	capacidad_auditiva TEXT,                -- Empareja con: nivel_auditivo_requerido
    capacidad_cognitiva TEXT,               -- Empareja con: carga_cognitiva_estimada
    destreza_tecnologica TEXT,              -- Empareja con: complejidad_tecnologica
    tiene_motilidad_fina BOOLEAN,           -- Empareja con: requiere_motilidad_fina
    idioma_materno TEXT,                    -- Empareja con: idiomas_disponibles
    usa_silla_ruedas BOOLEAN,               -- Empareja con: tipo_anclaje_silla
    etapa_enfermedad TEXT,                  -- Empareja con: es_escalable
    entorno_uso_principal TEXT              -- Empareja con: grado_portabilidad
);