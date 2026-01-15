import { initAll as govUKFrontendInitAll } from 'govuk-frontend'
import * as jquery from 'jquery'
window.jQuery = jquery
window.$ = jquery

govUKFrontendInitAll()
