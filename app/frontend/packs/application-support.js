import { initAll as govUKFrontendInitAll } from 'govuk-frontend'
import filter from './components/paginated_filter'
import { initAutocomplete } from './autocompletes/init-autocomplete'
import { supportAutocompleteInputs } from './autocompletes/support/support-autocomplete-inputs'
import sortByFilter from './sort-by-filter'

require.context('govuk-frontend/dist/govuk/assets')

govUKFrontendInitAll()

supportAutocompleteInputs.forEach((autocompleteInput) => {
  initAutocomplete(autocompleteInput)
})

filter()
sortByFilter()
