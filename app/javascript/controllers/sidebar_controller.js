// app/javascript/controllers/sidebar_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "panel", "overlay" ] // Definimos los targets que vamos a manipular

  connect() {
    // console.log("Sidebar controller connected!");
    // Opcional: Cerrar con la tecla Escape
    this.boundCloseOnEscape = this.closeOnEscape.bind(this)
  }

  open() {
    if (this.hasPanelTarget) {
      this.panelTarget.classList.add("is-open");
    }
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.add("is-visible");
      document.body.style.overflow = 'hidden'; // Evita scroll en el body
    }
    document.addEventListener('keydown', this.boundCloseOnEscape);
  }

  close() {
    if (this.hasPanelTarget) {
      this.panelTarget.classList.remove("is-open");
    }
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.remove("is-visible");
      document.body.style.overflow = ''; // Restaura scroll en el body
    }
    document.removeEventListener('keydown', this.boundCloseOnEscape);
  }

  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close();
    }
  }

  // Estas funciones son placeholders para cuando tengamos un formulario real
  applyFilters() {
    console.log("Apply filters clicked - form submission logic to be added");
    // Aquí iría la lógica para enviar el formulario de filtros o recargar la página con parámetros
    this.close(); // Cierra el sidebar después de "aplicar"
  }

  resetFilters() {
    console.log("Reset filters clicked - form reset logic to be added");
    // Aquí iría la lógica para limpiar los filtros y recargar
    // Por ejemplo, redirigir a movies_path sin parámetros de filtro.
    window.location.href = '/movies'; // Ejemplo simple de resetear
    this.close();
  }

  disconnect() {
    document.removeEventListener('keydown', this.boundCloseOnEscape);
  }
}