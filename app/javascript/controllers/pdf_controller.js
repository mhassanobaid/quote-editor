import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "status", "link"]
  static values = { url: String, statusUrl: String }

  connect() {
    this.maxAttempts = 15   // stop polling after ~30 sec
    this.attempts = 0
  }

  async generate() {
    console.log("NEW GENERATION STARTED")

    // STOP previous polling
    if (this.interval) clearInterval(this.interval)

    // RESET state
    this.linkTarget.classList.add("hidden")
    this.linkTarget.href = ""
    this.statusTarget.innerText = "⏳ PDF is generating..."
    this.buttonTarget.classList.add("hidden")
    this.attempts = 0

    try {
      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        }
      })

      if (!response.ok) throw new Error("Failed to start PDF generation")

      this.poll()

    } catch (error) {
      this.handleError("❌ Failed to start PDF generation")
    }
  }

  poll() {
    this.interval = setInterval(async () => {
      this.attempts++

      // STOP if too many attempts
      if (this.attempts > this.maxAttempts) {
        clearInterval(this.interval)
        this.handleError("❌ Timeout: PDF took too long")
        return
      }

      try {
        const res = await fetch(this.statusUrlValue)

        if (!res.ok) throw new Error("Status check failed")

        const data = await res.json()

        // HANDLE FAILED STATUS (backend should send this ideally)
        if (data.status === "failed") {
          clearInterval(this.interval)
          this.handleError("❌ PDF generation failed")
          return
        }

        if (data.status === "completed" && data.url) {
          clearInterval(this.interval)

          this.statusTarget.innerText = "✅ Ready"

          this.linkTarget.href = data.url
          this.linkTarget.classList.remove("hidden")

          // window.open(data.url, "_blank")

          this.buttonTarget.classList.remove("hidden")
          return
        }

        this.statusTarget.innerText = "⏳ Processing..."

      } catch (error) {
        clearInterval(this.interval)
        this.handleError("❌ Network error while checking status")
      }

    }, 2000)
  }

  downloaded() {
    // delay to ensure new tab opens properly
    setTimeout(() => {
      this.linkTarget.classList.add("hidden")
      this.statusTarget.innerText = ""
      this.buttonTarget.classList.remove("hidden")
      this.buttonTarget.innerText = "Generate PDF"
    }, 300)
  }

  handleError(message) {
    console.error(message)

    this.statusTarget.innerText = message

    this.buttonTarget.classList.remove("hidden")
    this.buttonTarget.innerText = "Try Again"
  }
}
