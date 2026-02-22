-- Limpiar duplicados
DELETE FROM criterios_evaluacion a
USING criterios_evaluacion b
WHERE a.nombre = b.nombre
  AND a.id < b.id;

-- Restricción UNIQUE
ALTER TABLE criterios_evaluacion
ADD CONSTRAINT nombre_unico UNIQUE (nombre);

-- Criterios base
INSERT INTO criterios_evaluacion (nombre, descripcion)
VALUES
('Interfaz','Facilidad de uso, carga cognitiva, accesibilidad visual...'),
('Hardware','Necesita pulsadores, mirada, pantalla táctil, sensores'),
('Software','Personalización, idioma, compatibilidad'),
('Adaptabilidad','Sirve para distintos niveles de discapacidad'),
('Portabilidad','Peso, tamaño, facilidad de uso en casa, escuela y calle'),
('Coste','Precio del sistema y mantenimiento'),
('Robustez','Tiene fallos, depende de batería'),
('Curva de aprendizaje','Fácil de aprender para usuarios y cuidadores')
ON CONFLICT (nombre) DO NOTHING;