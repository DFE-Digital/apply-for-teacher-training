require.context('govuk-frontend/assets');
import { initAll as govUKFrontendInitAll } from 'govuk-frontend';

import '../styles/application.scss';
govUKFrontendInitAll();
