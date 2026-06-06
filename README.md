![Cabecera EPS](img/cabecera_EPS.png)
![Logo GIS](img/Logo_GIS.png)

# Sistema de recomendación de SAAC para pacientes con ELA (2026)

**Alumna:** Lucía Gil Aire  
**Grado:** Ingeniería de la Salud  
**Institución:** [Universidad de Burgos](https://www.ubu.es)  
**En colaboración con:** [ELACyL (Asociación de Esclerosis Lateral Amiotrófica de Castilla y León)](https://www.elacyl.org)  
**Acceso a la aplicación:** [Cuestionario TFG - Sistema Recomendador](https://cuestionario-tfg.onrender.com/)


## Resumen / Abstract

### 🇪🇸 Resumen
Este trabajo se centra en la búsqueda de una solución tecnológica e ingenieril a la necesidad clínica de la pérdida de la comunicación en pacientes con Esclerosis Lateral Amiotrófica (ELA). El objetivo es la creación de un Sistema de Apoyo a la Decisión (SAD) asistido por base de datos para la recomendación de Sistemas Aumentativos y Alternativos de Comunicación (SAAC) según distintas variables como la progresión de la enfermedad o características del entorno. 

Durante el desarrollo del proyecto se han estudiado las bases fisiopatológicas de la ELA y el impacto de los SAAC en la calidad de vida de los pacientes. Por otro lado, se ha recopilado y estructurado un catálogo de soluciones tecnológicas actuales para predefinir los criterios de filtrado.

Tras la obtención de la idea y la captura de requerimientos clínicos, se diseñó e implementó una arquitectura web basada en una base de datos relacional PostgreSQL y un backend desarrollado en Python con Flask. El sistema evalúa de forma dinámica, mediante un motor de lógica proposicional (reglas IF-THEN) y consultas SQL avanzadas, la interacción entre las capacidades remanentes del usuario (visual, cognitiva, motora, auditiva y de habla) y los requisitos técnicos de los sistemas. La interfaz de usuario dinámica se generó utilizando el motor de plantillas Jinja2, HTML y hojas de estilo CSS optimizadas y securizadas bajo estándares OWASP.

La versión final del sistema consigue realizar una recomendación clínica precisa de las soluciones óptimas, incluyendo además propuestas preventivas como el *Voice Banking*. Al tratarse de un sistema validado mediante perfiles tipo, se ofrecen diferentes líneas para seguir escalando el proyecto en el futuro, incluyendo la integración de algoritmos de aprendizaje automático.

### 🇬🇧 Abstract
This work focuses on finding a technological and engineering solution to the clinical need of the loss of communication in patients with Amyotrophic Lateral Sclerosis (ALS). The main goal is the creation of a Database-Assisted Decision Support System (DSS) for the optimal recommendation of Aumentative and Alternative Communication (AAC) systems based on different parameters as disease progression and enviroment characteristics. 

During the development of the project, the pathophysiological foundations of ALS and the impact of AAC on patients quality of life were studied. On the other hand, a catalog of current technological solutions was compiled and structured to predefine the filtering criteria.

After establishing the core concept and capturing clinical requirements, a web architecture was designed and implemented based on a PostgreSQL relational database and a Python backend developed with Flask. The system dynamically evaluates, through a propositional logic engine (IF-THEN rules) and advanced SQL queries, the interaction between the user's remaining capabilities (visual, cognitive, motor, auditory, and speech) and the technical requirements of the systems. The dynamic user interface was generated using the Jinja2 template engine, HTML, and CSS stylesheets, fully optimized and secured under OWASP standards.

The final version of the system achieves accurate clinical recommendation of optimal solutions, also incorporating preventive proposals such as *Voice Banking*. Since the system was validated using standard user profiles, different tracks are provided to further scale the project in the future, including the integration of machine learning algorithms.



## Introducción

Este trabajo surge ante la compleja realidad a la que se enfrentan las personas con ELA y los profesionales sanitarios que los atienden. Una de las mayores dificultades comunicadas por la literatura clínica y las asociaciones es el carácter cambiante y progresivo de la enfermedad, lo que obliga a reevaluar constantemente qué tecnología de apoyo es la adecuada para el paciente en cada fase. 

Elegir un sistema erróneo o a destiempo puede frustrar al paciente y aislarlo comunicativamente. Por ello, la principal motivación que se persigue en este proyecto es la búsqueda de una herramienta de software médica interactiva, rigurosa y de bajo coste que automatice este proceso de decisión, garantizando que el paciente reciba la alternativa de comunicación óptima en el momento preciso.



## Objetivos del proyecto

Inicialmente, se plantean una serie de objetivos, para los cuales se obtendrá respuesta tras el análisis correspondiente de los datos:

* **Comprender los fundamentos fisiopatológicos de la ELA**, las diferentes tipologías de inicio de la enfermedad (bulbar o espinal) y cómo afectan a las capacidades comunicativas.
* **Estudiar y recopilar el catálogo de dispositivos y software actuales** destinados a la comunicación aumentativa y alternativa (SAAC), categorizándolos sistemáticamente.
* **Implementar una base de datos relacional estructurada (PostgreSQL)** que actúe como base de conocimiento clínico para el almacenamiento de soluciones y requerimientos del usuario.
* **Desarrollar un motor lógico basado en reglas de lógica proposicional** utilizando Python y Flask para el filtrado dinámico de las soluciones del catálogo.
* **Implementar medidas de seguridad web** siguiendo los estándares de OWASP (mediante Flask-Talisman) para proteger la navegación y las cookies de sesión.
* **Diseñar una vista legal y de consentimiento informado explícito** de acuerdo con el Reglamento General de Protección de Datos (RGPD) para el manejo seguro de datos de salud.
* **Crear un banco de pruebas de caja negra** y perfiles de usuario tipo para validar y estresar la fiabilidad clínica del algoritmo recomendador.
* **Aunar los conocimientos sanitarios y técnicos** adquiridos a lo largo del grado en Ingeniería de la Salud.
* **Emplear Overleaf como editor LaTeX** para la creación de los documentos entregables de la memoria.
* **Realizar un trabajo reproducible** en el futuro para que el sistema de recomendación pueda actualizarse o escalarse con nuevos dispositivos del mercado gracias a la estructura modular desarrollada.



## Contenidos del repositorio

A continuación se detalla la estructura de ficheros y directorios que forman este repositorio:

### Recursos gráficos
* img/: Carpeta dónde se incluyen todas las imágenes y diagramas de arquitectura que se han empleado en el desarrollo del proyecto.

### Documentación de la memoria (`tex/`)
Esta carpeta incluye todos los capítulos de la memoria en formato LaTeX necesarios para la compilación del documento:

* 1_introduccion.tex: Contexto clínico de la ELA, conceptos básicos de los SAAC y estado del arte.
* 2_objetivos.tex: Definición detallada de los objetivos del proyecto.
* 3_teoricos.tex: Marco conceptual del proyecto.
* 4_metodologia.tex: Descripción de los datos (catálogo), herramientas de desarrollo (Flask, PostgreSQL, Jinja2) y modelado de la lógica proposicional.
* 5_resultados.tex: Resultados detallados obtenidos en el proyecto.
* 6_discusion.tex: Discusión e interpretación de los resultados clínicos y técnicos.
* 7_conclusiones.tex: Cierre del proyecto con las conclusiones obtenidas.
* 8_lineas_futuras.tex: Propuestas de mejora y escalabilidad del recomendador (Machine Learning).
* A_planificacion.tex: Anexo relativo a la planificación temporal y económica.
* B_diseno.tex: Especificación del diseño del software y su arquitectura correspondiente.
* C_requisitos.tex: Requisitos técnicos necesarios para hacer uso e instalar el proyecto.
* D_manual_usuario.tex: Manual de usuario orientado a profesionales clínicos/usuarios finales.
* E_diseno.tex: Especificaciones de diseño para desarrolladores externos (replicabilidad).
* F_datos.tex: Estructuras de datos y fragmentos de código JSON del sistema.
* G_experimental.tex: Registro de las pruebas de caja negra realizadas sobre el motor de recomendación.
* H_ODS.tex: Documento de sostenibilización curricular (Objetivos de Desarrollo Sostenible).
* I_prompts.tex: Documento de transparencia en cuanto al uso de Inteligencia Artificial.

### Código fuente (`backend/`)
Contiene todo el código fuente correspondiente a la aplicación web:
* templates/: Directorio con los archivos Python (algoritmo de recomendación y archivos de conexión con la base de datos).
*   app.py: Archivo principal de la aplicación Flask. Contiene el algoritmo recomendador, las rutas web y la lógica de seguridad implementada con Flask-Talisman.
*   modelos.py: Script que define el modelo de datos relacional mediante el ORM SQLAlchemy. Declara las clases Python traducidas a tablas de PostgreSQL, gestionando relaciones de cardinalidad (muchos a muchos en plataformas, tipos de entrada, entornos de uso y parametrización de umbrales clínicos 0-3).
* static/estilos/: Directorio que aloja las hojas de estilo CSS optimizadas para la maquetación por pestañas de la interfaz.

### Base de datos (`Base de datos/`)
Archivos SQL estructurados para el despliegue del almacenamiento del conocimiento clínico:
* TFG.sql: Archivo usado para la configuración de la base de datos en entorno local.
* TFG_NUBE.sql: Archivo configurado para el despliegue de la base de datos en la nube.

### Entregables finales y configuración
* memoria.pdf: Documento PDF que contiene la memoria principal del TFG completa.
* anexos.pdf: Documento PDF que contiene el compendio completo de anexos.
* bibliografia.bib y bibliografiaAnexos.bib: Archivos BibTeX que recogen todas las referencias bibliográficas y fuentes científicas utilizadas tanto en la memoria como en los anexos.
* .gitignore: Archivo de configuración de Git encargado de omitir directorios temporales, entornos virtuales (`.venv`), credenciales locales y archivos auxiliares de la compilación de LaTeX.
