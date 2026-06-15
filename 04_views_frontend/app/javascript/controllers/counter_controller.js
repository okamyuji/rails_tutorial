import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display"]
  static values = { count: Number }

  increment() {
    this.countValue++
  }

  countValueChanged() {
    this.displayTarget.textContent = this.countValue
  }
}
