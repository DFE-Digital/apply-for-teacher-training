import { initAll as govUKFrontendInitAll } from 'govuk-frontend'
import filter from './components/paginated_filter'
import 'accessible-autocomplete/dist/accessible-autocomplete.min.css'
import '../styles/application-support.scss'
import { initAutocomplete } from './autocompletes/init-autocomplete'
import { supportAutocompleteInputs } from './autocompletes/support/support-autocomplete-inputs'
import sortByFilter from './sort-by-filter'

// stimulus
import { Application } from '@hotwired/stimulus'
import LocationAutocompleteController from './controllers/location_autocomplete_controller'

require.context('govuk-frontend/dist/govuk/assets')

window.Stimulus = Application.start()
window.Stimulus.register('location-autocomplete', LocationAutocompleteController)

govUKFrontendInitAll()

supportAutocompleteInputs.forEach((autocompleteInput) => {
  initAutocomplete(autocompleteInput)
})

filter()
sortByFilter()
