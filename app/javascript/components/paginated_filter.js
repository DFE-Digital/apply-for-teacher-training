/* eslint-disable no-new */
import { FilterToggleButton } from '@ministryofjustice/frontend'

const filter = () => {
  new FilterToggleButton({
    bigModeMediaQuery: '(min-width: 48.063em)',
    startHidden: false,
    toggleButton: {
      container: $('.filter-toggle-button'),
      showText: 'Show filters',
      hideText: 'Hide filters',
      classes: 'govuk-button--secondary'
    },
    closeButton: {
      container: $('.moj-filter__header-action'),
      text: 'Close'
    },
    filter: {
      container: $('.moj-filter-layout__filter')
    }
  })
}
/* eslint-enable no-new */

export default filter
