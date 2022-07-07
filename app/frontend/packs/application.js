import { initAll as govUKFrontendInitAll } from 'govuk-frontend'
import '../styles/application.scss'

require.context('govuk-frontend/govuk/assets')

govUKFrontendInitAll()
