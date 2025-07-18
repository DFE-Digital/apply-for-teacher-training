import { initAll as govUKFrontendInitAll } from 'govuk-frontend'
import initWarnOnUnsavedChanges from './warn-on-unsaved-changes'
import initAddFurtherConditions from './further_conditions'
import filter from './components/paginated_filter'
import checkboxSearchFilter from './components/checkbox_search_filter'
import '../styles/application-provider.scss'
import cookieBanners from './cookies/cookie-banners'
import 'accessible-autocomplete/dist/accessible-autocomplete.min.css'

// stimulus
import { Application } from '@hotwired/stimulus'
import LocationAutocompleteController from './controllers/location_autocomplete_controller'
import CopyToClipboardController from './controllers/copy_to_clipboard_controller.js'
import showMoreShowLess from './components/show-more-show-less'
import personalStatementToggle from './components/toggle_personal_statement'

require.context('govuk-frontend/dist/govuk/assets')

window.Stimulus = Application.start()
window.Stimulus.register('location-autocomplete', LocationAutocompleteController)
window.Stimulus.register('copy-to-clipboard', CopyToClipboardController)

govUKFrontendInitAll()
initWarnOnUnsavedChanges()
initAddFurtherConditions()
checkboxSearchFilter('subject', 'Search for subject')
filter()
cookieBanners()
showMoreShowLess()
personalStatementToggle()
