import { initAll as govUKFrontendInitAll } from 'govuk-frontend'
import '../styles/application-api-docs.scss'

require.context('govuk-frontend/govuk/assets')

govUKFrontendInitAll()
