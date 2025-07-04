import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['button', 'successTag']
  static values = { text: String }

  connect () {
    // Feature works only for javascript enabled users
    this.buttonTarget.classList.remove('govuk-visually-hidden')
  }

  call (event) {
    event.preventDefault()

    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    navigator.clipboard.writeText(this.textValue)
    this.successTagTarget.hidden = false

    this.timeout = setTimeout(() => {
      this.successTagTarget.hidden = true
    }, 5000)
  }
}
