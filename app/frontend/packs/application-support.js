import { initAll as govUKFrontendInitAll } from 'govuk-frontend'
import '../styles/application-support.scss'
import filter from './components/paginated_filter'
import 'accessible-autocomplete/dist/accessible-autocomplete.min.css'
import { initAutocomplete } from './autocompletes/init-autocomplete'
import { supportAutocompleteInputs } from './autocompletes/support/support-autocomplete-inputs'

require.context('govuk-frontend/govuk/assets')

govUKFrontendInitAll()

supportAutocompleteInputs.forEach((autocompleteInput) => {
  initAutocomplete(autocompleteInput)
})

filter()
