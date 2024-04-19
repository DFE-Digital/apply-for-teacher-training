import { initAll as govUKFrontendInitAll } from 'govuk-frontend'
import initWarnOnUnsavedChanges from './warn-on-unsaved-changes'
import { initAutocomplete } from './autocompletes/init-autocomplete'
import { initAutosuggest } from './autosuggests/init-autosuggest'
import { candidateAutocompleteInputs } from './autocompletes/candidate/candidate-autocomplete-inputs'
import { candidateAutosuggestInputs } from './autosuggests/candidate/candidate-autosuggest-inputs'
import nationalitiesComponent from './nationalities-component'
import cookieBanners from './cookies/cookie-banners'
import showMoreShowLess from './components/show-more-show-less'

require.context('govuk-frontend/dist/govuk/assets')

govUKFrontendInitAll()

candidateAutocompleteInputs.forEach((autocompleteInput) => {
  initAutocomplete(autocompleteInput)
})

candidateAutosuggestInputs.forEach((autoSuggestInput) => {
  initAutosuggest(autoSuggestInput)
})

initWarnOnUnsavedChanges()
nationalitiesComponent()
cookieBanners()
showMoreShowLess()
