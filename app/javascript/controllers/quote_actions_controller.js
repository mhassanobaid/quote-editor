import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { id: Number }

  connect() {
    this.loadActions()
  }

  loadActions() {
    fetch(`/quotes/${this.idValue}/actions`, {
      headers: {
        "Accept": "text/html"
      }
    })
      .then(response => response.text())
      .then(html => {
        this.element.innerHTML = html
      })
      .catch(error => {
        console.error("Failed to load quote actions:", error)
      })
  }
}
