🌎 Language: [English](README.md) | [Spanish](README.es.md)

# Spatial Crime Analysis in Mexico City

Geospatial analysis of crime in Mexico City using **network-based KDE** and **Getis-Ord Gi\***.  
This project generates **hotspot** and **coldspot** maps of robbery events, following a **network-constrained spatial analysis** approach.

---

## 🚨 Interactive Dashboard

> 📊 **Live interactive dashboard:**  
> 👉 [🔗 CLICK HERE TO OPEN THE DASHBOARD](https://hectoralfa.github.io/Analisis-Espacial-del-Crimen-en-la-CDMX/)

Or use this button:

[![Open interactive dashboard](https://img.shields.io/badge/Open%20dashboard-Interactive-blue?style=for-the-badge&logo=Tableau)](https://hectoralfa.github.io/Analisis-Espacial-del-Crimen-en-la-CDMX/)

---

## 🧩 Overview

This project analyzes the **spatial distribution of robbery crimes in Mexico City** using the **road network** as the primary spatial support. Through the use of:

- Road network analysis  
- Lixel-based segmentation  
- Graph representations  
- **Network-based Kernel Density Estimation (KDE)**  
- **Getis-Ord Gi\*** statistic for hotspot and coldspot detection  

an **interactive dashboard** is developed to explore high-risk areas for the most common robbery categories:  
**public transportation robbery, street robbery, and business robbery** along Mexico City’s road network.

The main goal of this project is to provide a useful tool for:

- **Public policy design and evaluation**  
- **Security analytics, risk assessment, and urban planning**

---

## 🎯 Project Objective

To develop a **geospatial digital tool** that:

- Collects, processes, and analyzes **road network data and robbery events**  
- Estimates the **concentration of criminal events along the road network**, rather than in continuous space  
- Identifies **high-risk street segments** using statistical methods (Getis-Ord Gi\*)  
- Enables **clear and accessible visualization** through an **interactive dashboard**

> 🔗 Quick access: [Open interactive dashboard](https://hectoralfa.github.io/Analisis-Espacial-del-Crimen-en-la-CDMX/)

---

## 🧠 Context and Motivation

The study of crime and violence requires an **integrated perspective** that combines:

- Characteristics of the **urban environment**  
- The structure and connectivity of the **road network**

Instead of analyzing only point patterns, this project focuses on **where daily life actually takes place: streets and roads**. This allows for:

- More accurate **risk exposure estimation**  
- Detection of **crime corridors**  
- Evidence-based **urban safety and planning decisions**

Although this project has a primarily **exploratory and descriptive** focus, its structure allows for the future integration of explanatory variables that may help understand the factors associated with these spatial patterns.

For example: socio-economic indicators, population density, proximity to public transportation, urban infrastructure, police presence, among others.

---

## 🗺️ Road Network Analysis

The core of the project is the **road network of Mexico City**, built using:

- Data from **INEGI** (Mexico’s national statistics agency)

The network is preprocessed to:

- Homogenize topology  
- Prepare the data for lixel-based and graph-based analysis

---

## 📏 Lixels: Network Segmentation

Once cleaned, the network is divided into small, uniform segments called **lixels** (line + pixel).

### Why is this useful?

- Enables **fine-grained and homogeneous** analysis  
- Facilitates computing **crime densities per segment**  
- Improves localization of **where exactly crimes concentrate**

Each lixel becomes an individual analytical unit for risk estimation.

---

## 🔗 Graph Representation

The road network is also represented as a **graph**. This representation allows:

- Modeling **urban connectivity**  
- Understanding how phenomena **propagate through the network**  
- Integrating graph-based metrics (distances, accessibility, etc.)

---

## 📈 Network-based Kernel Density Estimation (KDE)

To analyze whether crimes concentrate in specific areas, this project uses **Kernel Density Estimation (KDE)**. However, instead of applying it to continuous space, it is applied:

> ✅ **Directly on the road network**, using lixels as the spatial support.

### What does KDE do here?

- Each robbery event generates a localized influence over the network  
- Overlapping influences increase the estimated density  
- The result is a **street-segment-level crime intensity map**

The method considers:

- **Bandwidth**: controls the size of the influence area  
- **Kernel type**: the Epanechnikov kernel is used because it:
  - Minimizes the **Mean Integrated Squared Error (MISE)**  
  - Has **compact support**, reducing computational cost  

---

## 🔥 Hotspot Detection: Getis-Ord Gi\*

While KDE highlights areas with high concentrations, it does not indicate whether these patterns are **statistically significant** or could arise by chance.

To address this, the **Getis-Ord Gi\*** statistic is applied to the lixels to:

- Distinguish between visually dense areas  
- And those that are **statistically significant when compared to their neighbors**

The results are visualized as:

- 🔴 **Hot spots**: street segments with significantly high concentrations  
- 🔵 **Cold spots**: street segments with significantly low concentrations  

These outputs feed directly into the interactive dashboard for intuitive interpretation.

---

## 🧪 Data Sources

Crime database:

- Investigation records from the **Mexico City Attorney General’s Office**  
- Includes **three robbery categories**: street robbery, public transportation robbery, and business robbery  
- Spatial coverage: **Mexico City**  
- Time span: **January–December 2023**

Road network data:

- **INEGI** – https://www.inegi.org.mx

---

## 🧮 Tools and Technologies

Main tools used:

- 📦 **R**  
  - **`spNetwork`** package for network-based KDE  
- Spatial and statistical analysis libraries  
- 📊 **d3.js** for interactive visualizations  
- 🌐 **HTML/CSS/JavaScript** for the dashboard interface  

---

## 📂 Repository Structure

```text
.
├── estilos/
│   ├── general.css
│   └── mapa.css
├── imagenes/
├── scripts/
│   ├── capa.js
│   ├── card-capas.js
│   ├── eventos_selector.js
│   ├── footer.js
│   ├── geocoder.js
│   ├── header.js
│   ├── main.js
│   ├── mapa_config.js
│   └── restablecer.js
├── scripts_r/
│   ├── crime_analysis.R
│   └── funciones.R
├── docs/
│   └── metodologia.md
├── index.html
├── README.es.md
└── README.md
```
🎓 Academic Relevance

This project demonstrates:

Network-constrained spatial crime modeling

Integration of KDE with spatial autocorrelation statistics

Urban-scale risk modeling

Reproducible and modular spatial analysis

Potential extensions:

Spatio-temporal modeling

Cross-city generalization

Comparative kernel analysis

Integration with socio-economic indicators

💼 Industry Relevance

This project showcases:

 - End-to-end geospatial system design

 - Risk mapping for urban safety

 - Interactive data products

 - Scalable spatial analytics

It can be used as a base for:

 - Crime prevention systems

 - Urban risk dashboards

 - Public safety monitoring

