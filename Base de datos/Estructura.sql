-- Tabla de los distintos sistemas SAAC
CREATE TABLE IF NOT EXISTS public.sistemas_saac
(
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL,
    descripcion TEXT,
    tipo TEXT,
    categoria TEXT
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.sistemas_saac
    OWNER to postgres;
	
-- Tabla de criterios de evaluación de los SAAC
CREATE TABLE IF NOT EXISTS public.criterios_evaluacion
(
    id integer NOT NULL DEFAULT nextval('criterios_evaluacion_id_seq'::regclass),
    nombre text COLLATE pg_catalog."default" NOT NULL,
    descripcion text COLLATE pg_catalog."default",
    CONSTRAINT criterios_evaluacion_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.criterios_evaluacion
    OWNER to postgres;
	
-- Tabla de valores de criterios por sistema (relación entre tablas)
CREATE TABLE IF NOT EXISTS public.valores_criterios
(
    id integer NOT NULL DEFAULT nextval('valores_criterios_id_seq'::regclass),
    sistema_id integer,
    criterio_id integer,
    valor text COLLATE pg_catalog."default",
    CONSTRAINT valores_criterios_pkey PRIMARY KEY (id),
    CONSTRAINT valores_criterios_criterio_id_fkey FOREIGN KEY (criterio_id)
        REFERENCES public.criterios_evaluacion (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT valores_criterios_sistema_id_fkey FOREIGN KEY (sistema_id)
        REFERENCES public.sistemas_saac (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.valores_criterios
    OWNER to postgres;