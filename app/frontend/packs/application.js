require.context('govuk-frontend/govuk/assets');
import { initAll as govUKFrontendInitAll } from 'govuk-frontend';

import '../styles/application.scss';
govUKFrontendInitAll();
