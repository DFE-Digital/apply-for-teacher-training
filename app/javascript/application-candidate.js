import { initAll as govUKFrontendInitAll } from 'govuk-frontend'
import initWarnOnUnsavedChanges from './utils/warn-on-unsaved-changes'
import { initAutocomplete } from './autocompletes/init-autocomplete'
import { initAutosuggest } from './autosuggests/init-autosuggest'
import { candidateAutocompleteInputs } from './autocompletes/candidate/candidate-autocomplete-inputs'
import { candidateAutosuggestInputs } from './autosuggests/candidate/candidate-autosuggest-inputs'
import nationalitiesComponent from './utils/nationalities-component'
import cookieBanners from './cookies/cookie-banners'
import initClarityCookies from './utils/clarity-initializer'

// stimulus
import { Application } from '@hotwired/stimulus'
import LocationAutocompleteController from './controllers/location_autocomplete_controller'
import ReadMoreReadLessController from './controllers/read_more_read_less_controller'

window.Stimulus = Application.start()
window.Stimulus.register('location-autocomplete', LocationAutocompleteController)
window.Stimulus.register('read-more-read-less', ReadMoreReadLessController)

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
initClarityCookies('apply')
