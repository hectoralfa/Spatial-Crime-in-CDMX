class HeaderGob extends HTMLElement {
  connectedCallback() {
    this.innerHTML = `
      <header class="barra-logo">
        <img src="imagenes/logo.png" alt="Logo" class="logo-izquierdo" >
        <div class="header-content">
          <h1>Robo por vialidades</h1>
        </div>
      </header>
    `;
  }
}

customElements.define('header-hc', HeaderGob);

