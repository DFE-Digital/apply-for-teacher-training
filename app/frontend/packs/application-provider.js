require.context("govuk-frontend/govuk/assets");

import { initAll as govUKFrontendInitAll } from "govuk-frontend";
import initWarnOnUnsavedChanges from "./warn-on-unsaved-changes";
import filter from "./components/paginated_filter";
import "../styles/application-provider.scss";

govUKFrontendInitAll();
initWarnOnUnsavedChanges();
filter();
