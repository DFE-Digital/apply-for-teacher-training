import { initAll as govUKFrontendInitAll } from 'govuk-frontend'
import initWarnOnUnsavedChanges from './warn-on-unsaved-changes'
import { initAutocomplete } from './autocompletes/init-autocomplete'
import { initAutosuggest } from './autosuggests/init-autosuggest'
import { candidateAutocompleteInputs } from './autocompletes/candidate/candidate-autocomplete-inputs'
import { candidateAutosuggestInputs } from './autosuggests/candidate/candidate-autosuggest-inputs'
import nationalitiesComponent from './nationalities-component'
import 'accessible-autocomplete/dist/accessible-autocomplete.min.css'
import '../styles/application-candidate.scss'
import cookieBanners from './cookies/cookie-banners'
import showMoreShowLess from './components/show-more-show-less'

// stimulus
import { Application } from '@hotwired/stimulus'
import LocationAutocompleteController from './controllers/location_autocomplete_controller'

require.context('govuk-frontend/dist/govuk/assets')

window.Stimulus = Application.start()
window.Stimulus.register('location-autocomplete', LocationAutocompleteController)

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
