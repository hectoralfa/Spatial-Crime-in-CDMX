# Spatial-Crime-Analysis-CDMX
Análisis geoespacial de delitos en la Ciudad de México utilizando KDE sobre red vial y  Getis-Ord Gi*. El proyecto genera mapas de hotspots y coldspots basados en puntos de crimen, empleando una metodología de análisis espacial en redes urbanas.
# Homicidios en la Red Vial de México 🚨🗺️

> 📊 **Tablero interactivo disponible aquí:**  
> 👉 [🔗 HAZ CLIC PARA VER EL TABLERO](https://hectoralfa.github.io/Spatial-Crime-Analysis-CDMX/)

o utiliza este botón:

[![Ver tablero interactivo](https://img.shields.io/badge/Ver%20tablero-Interactivo-blue?style=for-the-badge&logo=Tableau)](TU_URL_DEL_TABLERO)

---

## 🧩 Descripción general

Este proyecto analiza la **distribución espacial de homicidios en México** utilizando la **red vial** como soporte principal. A través de técnicas de:

- Análisis de red vial  
- Segmentación en *lixels*  
- Representación como grafo  
- **Kernel Density Estimation (KDE)** sobre red  
- Estadístico **Getis-Ord Gi\*** para identificación de *hotspots*  

se construye un **tablero interactivo** que permite explorar zonas con mayor riesgo de homicidios a lo largo de las vías de comunicación del país.

El objetivo es aportar una herramienta útil para:

- **Investigación académica y postgrados**
- **Diseño y evaluación de políticas públicas**
- **Áreas de seguridad, análisis de riesgo y planeación urbana**
- **Reclutadores y equipos de datos** interesados en ciencia de datos aplicada a problemas públicos.

---

## 🎯 Objetivo del proyecto

Desarrollar una **herramienta digital geoespacial** que:

- Recopile, procese y analice información sobre **redes viales y homicidios**.  
- Estime la **concentración de eventos delictivos** sobre la red vial, no solo sobre el espacio continuo.  
- Identifique **tramos de calle** con riesgo elevado mediante técnicas estadísticas (Getis-Ord Gi\*).  
- Permita **visualizar los resultados** de forma clara y accesible mediante un **tablero interactivo**.

> 🔗 Acceso rápido: [Ver tablero interactivo](TU_URL_DEL_TABLERO)

---

## 🧠 Contexto y motivación

El estudio del crimen y la violencia requiere una mirada **integral** que combine:

- Factores **sociales y económicos**
- Características del **entorno urbano**
- Estructura y conectividad de la **red vial**

En lugar de analizar solo puntos en un mapa, este proyecto considera **por dónde se mueve la vida cotidiana: las calles y carreteras**. Esto permite:

- Estimar mejor la **exposición al riesgo**  
- Detectar **corredores de violencia**  
- Apoyar decisiones de **seguridad y planeación urbana** con evidencia espacial.

---

## 🗺️ Análisis de la red vial

La base del proyecto es la **red vial de México**, construida a partir de:

- Información del **INEGI**  
- Datos complementarios de **OpenStreetMap (OSM)**

Ambas fuentes se integran para reducir vacíos en la red vial, corrigiendo problemas como:

- Segmentos desconectados  
- Tramos faltantes  
- Inconsistencias topológicas

Este preprocesamiento se realiza principalmente en **QGIS**, aprovechando su capacidad para el manejo de datos geoespaciales.

---

## 📏 Lixels: segmentando la red

Una vez limpia la red, se divide en **segmentos pequeños y uniformes** llamados *lixels* (line + pixel).

¿Por qué es útil?

- Permite analizar la red a una escala más **fina y homogénea**.  
- Facilita calcular **densidades** de homicidios por tramo.  
- Ayuda a localizar con mayor precisión **en qué parte de una calle se concentran los eventos**.

Cada lixel se convierte en una unidad de análisis sobre la cual se calculan indicadores de riesgo.

---

## 🔗 Representación como grafo

La red vial también se representa como un **grafo**:

- **Nodos** → cruces o intersecciones  
- **Aristas** → tramos de calle entre intersecciones  

Esta representación permite:

- Modelar la **conectividad** de la ciudad/región  
- Entender cómo se pueden **propagar fenómenos** a lo largo de la red  
- Integrar métricas de red (distancias, accesibilidad, rutas mínimas, etc.)

---

## 📈 Kernel Density Estimation (KDE) sobre la red vial

Para analizar si los homicidios se concentran en ciertas zonas, se utiliza **Kernel Density Estimation (KDE)**, pero en lugar de aplicarlo al espacio continuo, se aplica:

> ✅ **Directamente sobre la red vial** utilizando los *lixels* como soporte.

### ¿Qué hace KDE en este proyecto?

- Cada homicidio genera una “mancha” de influencia sobre la red.  
- Si varias manchas se superponen en un mismo tramo, se estima una **mayor densidad de homicidios**.  
- El resultado es un mapa de **intensidad de homicidios por tramo de calle**.

Se consideran:

- **Ancho de banda (*bandwidth*)**: controla el tamaño de la mancha.  
- **Tipo de kernel**: en este caso, se utiliza el **kernel de Epanechnikov**, que:
  - Minimiza el **error cuadrático medio integrado (MISE)**  
  - Tiene **soporte compacto**, lo que reduce el costo computacional.

---

## 🔥 Identificación de hotspots: Getis-Ord Gi\***

KDE muestra dónde hay **concentraciones altas**, pero no dice si estas son **estadísticamente significativas**.

Para eso se utiliza el estadístico **Getis-Ord Gi\*** sobre los lixels, con el fin de:

- Distinguir entre zonas que solo “parecen” densas  
- Y aquellas que, **estadísticamente**, tienen **muchos más homicidios de lo esperado** en comparación con sus vecinos.

El resultado se visualiza en forma de:

- 🔴 **Zonas calientes (hot spots)**: tramos con concentración significativamente alta  
- 🔵 **Zonas frías (cold spots)**: tramos con concentración significativamente baja  

Estos resultados alimentan el **tablero interactivo** para una interpretación más intuitiva.

---

## 🧪 Datos utilizados

La base de homicidios se construyó a partir de:

- Registros de homicidios de **fiscalías estatales**  
- Incluye **todos los tipos de homicidio**, sin distinguir modalidad  
- Cobertura: **32 estados de México**  
- Periodo: **enero–marzo de 2025**  
- Total de registros: **12,669 homicidios**

La red vial proviene de:

- **INEGI** – [https://www.inegi.org.mx](https://www.inegi.org.mx)  
- **OpenStreetMap** – [https://www.openstreetmap.org](https://www.openstreetmap.org)

---

## 🧮 Herramientas y tecnologías

Algunas de las herramientas utilizadas:

- 🗺️ **QGIS** – limpieza y preparación de la red vial  
- 📦 **R** (o tu lenguaje principal de análisis, ajústalo si usaste otro)  
  - Paquete **`spNetwork`** para KDE sobre red vial  
- 🧪 Librerías para análisis estadístico y espacial  
- 📊 Herramientas de visualización / BI (por ejemplo, Tableau, Power BI, Shiny, etc. – ajusta según tu caso)

---

## 📂 Estructura del repositorio

Ejemplo de estructura (ajusta a tu repo real):

```text
.
├── data/
│   ├── raw/                # Datos originales (INEGI, OSM, fiscalías)
│   └── processed/          # Red vial limpia y datos procesados
├── src/
│   ├── 01_preprocesamiento_red.R
│   ├── 02_kde_red_vial.R
│   ├── 03_getis_ord.R
│   └── utils/
├── dashboards/
│   └── tablero_homicidios/ # Archivos del tablero (si aplica)
├── docs/
│   └── metodologia.md
└── README.md
