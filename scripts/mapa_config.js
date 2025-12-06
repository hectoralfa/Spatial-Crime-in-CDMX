import { aplicarFiltros } from './capas.js';

// =========================
// VARIABLES GLOBALES
// =========================
let marker = null;
export let municipiosGeoJson = null;
export let estadosGeoJson = null;
export const cargarCallesPorEstado = (codigoEntidad) => {
  const source = window.map.getSource("calles");
  if (!source) {
    console.error("La fuente 'calles' no está disponible en el mapa.");
    return;
  }

  const rutaCalles = `https://lustrous-pavlova-9dc611.netlify.app/calles${codigoEntidad}.geojson`;
  source.setData(rutaCalles);
  console.log(`Calles cargadas para el estado ${codigoEntidad}: ${rutaCalles}`);
};
let bboxNacional = null;

window.map = new maplibregl.Map({
  container: 'map',
  style: 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json',
  center: [-99.1332, 19.4326],
  zoom: 5
});

window.currentPopup = null;

// =========================
// INICIALIZACIÓN AL CARGAR DOM
// =========================
if (typeof window !== "undefined") {
  // @ts-ignore
  window.map = window.map;
}

document.addEventListener('DOMContentLoaded', function () {
  const esperarMapa = setInterval(() => {
    if (window.map && typeof window.map.on === 'function' && window.map.isStyleLoaded()) {
      clearInterval(esperarMapa);

      // Inicializar capas y fuentes aquí
      console.log("El mapa está listo para modificar capas y fuentes.");

      Promise.all([
        fetch("https://lustrous-pavlova-9dc611.netlify.app/entidades.geojson")
          .then(r => r.json())
          .then(data => {
            estadosGeoJson = data;
            bboxNacional = turf.bbox(estadosGeoJson);
            console.log("Datos de entidades cargados:", estadosGeoJson);
          })
          .catch(err => console.error("Error al cargar entidades:", err)),

        fetch("https://lustrous-pavlova-9dc611.netlify.app/municip_poblacion.geojson")
          .then(r => r.json())
          .then(data => {
            municipiosGeoJson = data;
            bboxNacional = turf.bbox(municipiosGeoJson);
            console.log("Datos de municipios cargados:", municipiosGeoJson);
            
            // Agregar la fuente de municipios al mapa
            window.map.addSource("municipios-source", {
              type: "geojson",
              data: municipiosGeoJson
            });

            // Agregar capas relacionadas con municipios
            window.map.addLayer({
              id: "municipio-fill",
              type: "fill",
              source: "municipios-source",
              paint: {
                "fill-color": "#FA0",
                "fill-opacity": 0.0  
              },
              layout: {
                visibility: "none"
              }
            });

            window.map.addLayer({
              id: "municipio-outline",
              type: "line", 
              source: "municipios-source",
              paint: {
                "line-color": "#B9BBC4",
                "line-width": 2
              },
              layout: {
                visibility: "none"
              }
            });
            
            // Disparar evento personalizado
            document.dispatchEvent(new Event("municipios-cargados"));
            console.log("Datos cargados correctamente.");
            setTimeout(() => {
              document.dispatchEvent(new Event("municipios-cargados"));
            }, 0);
          })
          .catch(err => console.error("Error al cargar municipios:", err))
      ]).then(() => {
        // Configurar eventos de capas
        const cardCapas = document.querySelector('card-capas');
        if (cardCapas) {
          cardCapas.addEventListener('layer-toggle', (e) => {
            const { layer, checked } = e.detail;
            if (window.map.getLayer(layer)) {
              window.map.setLayoutProperty(layer, 'visibility', checked ? 'visible' : 'none');
            }
          });
        }

        // Configurar botón de reset
        const resetBtn = document.querySelector('boton-reset-mapa');
        if (resetBtn) {
          const resetButton = resetBtn.querySelector('#reset-button');
          resetButton.addEventListener('click', () => {
            resetBtn.resetMapView(resetButton);
          });
        }
      });
    }
  }, 100);
});

// =========================
// CONFIGURACIÓN DEL MAPA Y CAPAS
// =========================
window.map.on("load", () => {
  configurarCapas().then(() => {
    const cardCapas = document.querySelector('card-capas');
    if (cardCapas) {
      setTimeout(() => {
        cardCapas.sincronizarCheckboxes();
        activarVistaNacional(); // O activarVistaLocal según el caso
      }, 100); // Esperar un poco para asegurar que las capas estén listas
    }
  });
});

// =========================
// FUNCIONES AUXILIARES
// =========================

// Configuración para vista nacional
function activarVistaNacional() {
  const cardCapas = document.querySelector('card-capas');
  if (cardCapas && typeof cardCapas.sincronizarCheckboxes === 'function') {
    cardCapas.toggleLayerControls(false); // Deshabilitar controles
    cardCapas.sincronizarCheckboxes(); // Sincronizar checkboxes
  }

  // Ajustar vista a nivel nacional
  if (window.bboxNacional) {
    window.map.fitBounds(window.bboxNacional, { padding: 20, duration: 1000 });
  }
}

// Configuración para vista estado/municipio
export function activarVistaLocal(codigoEntidad, nivel) {
  const cardCapas = document.querySelector('card-capas');
  if (cardCapas) {
    cardCapas.toggleLayerControls(true, nivel === 'municipio'); // Habilitar controles y prender "Calles" si es municipio
  }

  const capas = ["robos-layer", "escuelas-layer", "calles-layer"];
  if (nivel === 'estado') {
    aplicarFiltros(capas, codigoEntidad, "CVE_ENT");
  } else if (nivel === 'municipio') {
    aplicarFiltros(capas, codigoEntidad, "CVEGEO");
  } else {
    console.error(`Nivel inválido: ${nivel}`);
    return;
  }

  // Sincronizar los checkboxes después de aplicar filtros
  if (cardCapas) {
    cardCapas.sincronizarCheckboxes();
  }
}

// Configuración de capas
function configurarCapas() {
  return new Promise((resolve) => {
    // Robos
    window.map.addSource("robos", {
      type: "geojson",
      data: "https://lustrous-pavlova-9dc611.netlify.app/delitos_robo.geojson"
    });
    window.map.addLayer({
      id: "robos-layer",
      type: "circle",
      source: "robos",
      paint: {
        "circle-radius": 4,
        "circle-color": "#1d1d1d",
        "circle-opacity": 0.8,
        "circle-stroke-color": "black",
        "circle-stroke-width": 1
      },
      filter: ["==", "CVE_ENT", ""]
    });
    window.map.setLayoutProperty("robos-layer", "visibility", "none");

    // Escuelas
    window.map.addSource("escuelas", {
      type: "geojson",
      data: "https://lustrous-pavlova-9dc611.netlify.app/escuelas.geojson"
    });
    window.map.loadImage('imagenes/escuela.png', (error, image) => {
      if (error) return console.error("Error al cargar imagen de escuelas", error);
      if (!window.map.hasImage('icono-escuela')) window.map.addImage('icono-escuela', image);
      window.map.addLayer({
        id: 'escuelas-layer',
        type: 'symbol',
        source: 'escuelas',
        layout: {
          'icon-image': 'icono-escuela',
          'icon-size': 0.02,
          'icon-allow-overlap': true
        },
        filter: ['==', 'CVE_ENT', '']
      });
      window.map.setLayoutProperty('escuelas-layer', 'visibility', 'none');
    });

    // Crear la fuente de calles inicialmente vacía
    window.map.addSource("calles", {
      type: "geojson",
      data: { type: "FeatureCollection", features: [] }, 
      buffer: 512,
      tolerance: 0.05
    });

    window.map.addLayer({
      id: "calles-layer",
      type: "line",
      source: "calles",
      layout: { visibility: "none" },
      paint: {
        "line-color": ["get", "colores"],
        "line-width": [
          "interpolate", ["linear"], ["zoom"],
          1, 0.2,
          7, 0.4,
          15, 1
        ]
      }
    });

    resolve({ cargarCallesPorEstado });
  });
}
