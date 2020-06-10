import { FilterToggleButton } from "moj/all.js";

const providerFilter = () => {
      new FilterToggleButton({
        bigModeMediaQuery: '(min-width: 48.063em)',
        startHidden: false,
        toggleButton: {
          container: $('.filter-toggle-button'),
          showText: 'Show filter',
          hideText: 'Hide filter',
          classes: 'govuk-button--secondary'
        },
        closeButton: {
          container: $('.moj-filter__header-action'),
          text: 'Close'
        },
        filter: {
          container: $('.moj-filter-layout__filter')
        }
      });
};

export default providerFilter;
