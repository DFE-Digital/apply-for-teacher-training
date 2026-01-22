import { initAll as govUKFrontendInitAll } from 'govuk-frontend'
import SortableTable from './sortable-table'

import '../styles/application-publications.scss'

require.context('govuk-frontend/dist/govuk/assets')
govUKFrontendInitAll()

/* eslint-disable no-new */
for (const table of document.querySelectorAll('table')) {
  new SortableTable(table)
}
/* eslint-enable no-new */
