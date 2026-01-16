/* eslint-disable no-new */
import { FilterToggleButton } from '@ministryofjustice/frontend'

const filter = () => {
  new FilterToggleButton({
    bigModeMediaQuery: '(min-width: 48.063em)',
    startHidden: false,
    toggleButton: {
      container: document.querySelector('.filter-toggle-button'),
      showText: 'Show filters',
      hideText: 'Hide filters',
      classes: 'govuk-button--secondary'
    },
    closeButton: {
      container: document.querySelector('.moj-filter__header-action'),
      text: 'Close'
    },
    filter: {
      container: document.querySelector('.moj-filter-layout__filter')
    }
  })
}
/* eslint-enable no-new */

export default filter
