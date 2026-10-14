import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input']

  connect () {}

  call (event) {
    event.preventDefault()

    this.inputTarget.closest('form')?.requestSubmit()
  }
}
