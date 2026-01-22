import { Controller } from '@hotwired/stimulus'
import dfeAutocomplete from 'dfe-autocomplete'

// Connects to data-controller="autocomplete"
export default class extends Controller {
  connect () {
    dfeAutocomplete({ rawAttribute: true, confirmOnBlur: false })
  }
}
