class FooterHC extends HTMLElement {
  connectedCallback() {
    this.innerHTML = `
      <footer class="footer-hc">
        <div class="footer-container">
          <div class="footer-logo">
            <img src="imagenes/chaco.png" alt="Logo Chaco" style="max-height:300px; height:auto; width:auto;" />
          </div>
          <div class="footer-col">
            <h4>Consulta de datos</h4>
            <p>
              Enlaces donde puede encontrar mayor información<br>
            </p>
            <ul>
              <li><a href="https://www.inegi.org.mx/temas/mg/" target="_blank" class="aviso-privacidad">Marco Geoestadístico</a></li>
              <li><a href="https://datos.cdmx.gob.mx/dataset/carpetas-de-investigacion-fgj-de-la-ciudad-de-mexico?" target="_blank" class="declaracion-accesibilidad">Carpetas de investigación</a></li>
              <li><a href="https://www.inegi.org.mx/temas/mg/" target="_blank" class="aviso-privacidad">Marco Geoestadístico</a></li>
              <li><a href="https://datos.cdmx.gob.mx/dataset/?groups=educacion-ciencia-y-tecnologia&res_format=SHP" target="_blank" class="aviso-privacidad">Escuelas en CDMX</a></li>
              <li><a href="https://datos.cdmx.gob.mx/dataset/espacio-publico-de-la-ciudad-de-mexico/resource/4c54880e-2c81-47ae-ac7f-416a3a7dde0c?" target="_blank" class="aviso-privacidad">Espacio público</a></li>
              <li><a href="https://hub.worldpop.org/geodata/summary?id=42481" target="_blank" class="aviso-privacidad">Densidad poblacional</a></li>

            </ul>
          </div>
          <div class="footer-col">
            <h4>Redes sociales </h4>
            <div class="redes">
              <a href="https://www.linkedin.com/in/héctor-olivares-561278219/" target="_blank" rel="noopener">
                <img src="imagenes/likendin.png" alt="Likendin" width="32" height="32" />
              </a>
              <a href="https://github.com/hectoralfa" target="_blank" rel="noopener">
                <img src="imagenes/github.png" alt="Github" width="32" height="32" />
              </a>
            </div>
          </div>
        </div>
      </footer>
    `;
  }
}
customElements.define('footer-hc', FooterHC);