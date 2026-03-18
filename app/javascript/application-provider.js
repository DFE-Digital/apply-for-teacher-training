import { initAll as govUKFrontendInitAll } from 'govuk-frontend'
import initWarnOnUnsavedChanges from './utils/warn-on-unsaved-changes'
import initAddFurtherConditions from './further_conditions'
import filter from './components/paginated_filter'
import checkboxSearchFilter from './components/checkbox_search_filter'
import cookieBanners from './cookies/cookie-banners'
import initClarityCookies from './utils/clarity-initializer'

// stimulus
import { Application } from '@hotwired/stimulus'
import LocationAutocompleteController from './controllers/location_autocomplete_controller'
import CopyToClipboardController from './controllers/copy_to_clipboard_controller.js'
import AutocompleteController from './controllers/autocomplete_controller'
import ReadMoreReadLessController from './controllers/read_more_read_less_controller'

window.Stimulus = Application.start()
window.Stimulus.register('location-autocomplete', LocationAutocompleteController)
window.Stimulus.register('copy-to-clipboard', CopyToClipboardController)
window.Stimulus.register('autocomplete', AutocompleteController)
window.Stimulus.register('read-more-read-less', ReadMoreReadLessController)

govUKFrontendInitAll()
initWarnOnUnsavedChanges()
initAddFurtherConditions()
checkboxSearchFilter('subject', 'Search for subject')
filter()
cookieBanners()
initClarityCookies('manage')
