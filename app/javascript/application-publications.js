import { initAll as govUKFrontendInitAll } from 'govuk-frontend'
import SortableTable from './utils/sortable-table'

govUKFrontendInitAll()

/* eslint-disable no-new */
for (const table of document.querySelectorAll('table')) {
  new SortableTable(table)
}
/* eslint-enable no-new */
