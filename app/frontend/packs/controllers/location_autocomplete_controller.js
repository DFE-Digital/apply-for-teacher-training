import { Controller } from '@hotwired/stimulus'
import accessibleAutocomplete from 'accessible-autocomplete'
import debounce from 'lodash.debounce'
import { request } from '../utils/request_helper'

export default class extends Controller {
  static targets = ['input']
  static values = {
    path: String,
    minLength: { type: Number, default: 3 },
    debounce: { type: Number, default: 200 }
  }

  connect () {
    if (!this.hasInputTarget) return
    this.setupAutocomplete()
  }

  setupAutocomplete () {
    const inputElement = this.inputTarget

    accessibleAutocomplete({
      element: inputElement.parentElement,
      id: inputElement.id,
      showNoOptionsFound: false,
      name: inputElement.name,
      defaultValue: inputElement.value,
      displayMenu: 'overlay',
      minLength: this.minLengthValue,
      source: this.fetchSuggestions(),
      templates: {
        inputValue: this.inputValueTemplate.bind(this),
        suggestion: this.suggestionTemplate.bind(this)
      },
      onConfirm: this.onConfirm.bind(this),
      confirmOnBlur: false
    })

    inputElement.remove()
  }

  fetchSuggestions () {
    return debounce((query, populateResults) => {
      if (!query) return populateResults([])

      new Promise((resolve) => {
        request(this.pathValue)(query, (data) => {
          resolve(data)
        })
      })
        .then((data) => {
          const suggestions = Array.isArray(data?.suggestions) ? data.suggestions : []
          populateResults(suggestions)
        })
        .catch(() => {
          populateResults([])
        })
    }, this.debounceValue)
  }

  suggestionTemplate (result) {
    if (typeof result === 'string') {
      return result
    }
    return result && typeof result.name === 'string' ? result.name : ''
  }

  inputValueTemplate (result) {
    return this.suggestionTemplate(result)
  }

  onConfirm () {}
}
