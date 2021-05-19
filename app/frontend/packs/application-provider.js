import { initAll as govUKFrontendInitAll } from 'govuk-frontend'
import initWarnOnUnsavedChanges from './warn-on-unsaved-changes'
import initAddFurtherConditions from './further_conditions'
import filter from './components/paginated_filter'
import checkbox_search_filter from './components/checkbox_search_filter'
import '../styles/application-provider.scss'
import cookieBanners from './cookies/cookie-banners'

require.context('govuk-frontend/govuk/assets')

govUKFrontendInitAll()
initWarnOnUnsavedChanges()
initAddFurtherConditions()
filter()
cookieBanners()
checkbox_search_filter('subject', 'Search for subject')
