import { initAll as govUKFrontendInitAll } from 'govuk-frontend'
import '../styles/application.scss'

require.context('govuk-frontend/dist/govuk/assets')

govUKFrontendInitAll()
