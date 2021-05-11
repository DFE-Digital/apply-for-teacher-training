import Rails from '@rails/ujs'
import { initAll as govUKFrontendInitAll } from 'govuk-frontend'
import initWarnOnUnsavedChanges from './warn-on-unsaved-changes'
import filter from './components/paginated_filter'
import '../styles/application-provider.scss'
import cookieBanners from './cookies/cookie-banners'

require.context('govuk-frontend/govuk/assets')

Rails.start()
govUKFrontendInitAll()
initWarnOnUnsavedChanges()
filter()
cookieBanners()
