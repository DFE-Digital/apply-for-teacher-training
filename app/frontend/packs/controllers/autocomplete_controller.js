import { Controller } from '@hotwired/stimulus'
import accessibleAutocomplete from 'accessible-autocomplete'

// Connects to data-controller="autocomplete"
export default class extends Controller {
  connect () {
    const selectElement = this.element

    // Replace "Select a ..." with empty string
    const emptyOption = selectElement.querySelector("[value='']")
    if (emptyOption) {
      emptyOption.innerHTML = ''
    }

    accessibleAutocomplete.enhanceSelectElement({
      selectElement,
      autoselect: false,
      confirmOnBlur: false,
      showAllValues: true
    })
  }
}
