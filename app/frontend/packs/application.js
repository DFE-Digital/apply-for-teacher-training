import { initAll as govUKFrontendInitAll } from 'govuk-frontend'

require.context('govuk-frontend/dist/govuk/assets')

govUKFrontendInitAll()
