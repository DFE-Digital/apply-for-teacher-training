import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'shortText',
    'remainingText',
    'moreLink',
    'lessLink'
  ]

  connect () {
    this.remainingTextTarget.hidden = true
    this.lessLinkTarget.hidden = true

    this.moreLinkTarget.hidden = false
  }

  showLess (event) {
    event.preventDefault()

    this.remainingTextTarget.hidden = true
    this.lessLinkTarget.hidden = true

    this.moreLinkTarget.hidden = false
    this.moreLinkTarget.focus = true
  }

  showMore (event) {
    event.preventDefault()

    this.moreLinkTarget.hidden = true

    this.remainingTextTarget.hidden = false
    this.lessLinkTarget.hidden = false
    this.lessLinkTarget.focus = true
  }
}
