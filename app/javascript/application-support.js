import { initAll as govUKFrontendInitAll } from 'govuk-frontend'
import filter from './components/paginated_filter'
import { initAutocomplete } from './autocompletes/init-autocomplete'
import { supportAutocompleteInputs } from './autocompletes/support/support-autocomplete-inputs'
import sortByFilter from './utils/sort-by-filter'

// stimulus
import { Application } from '@hotwired/stimulus'
import LocationAutocompleteController from './controllers/location_autocomplete_controller'

window.Stimulus = Application.start()
window.Stimulus.register('location-autocomplete', LocationAutocompleteController)

govUKFrontendInitAll()

supportAutocompleteInputs.forEach((autocompleteInput) => {
  initAutocomplete(autocompleteInput)
})

filter()
sortByFilter()
