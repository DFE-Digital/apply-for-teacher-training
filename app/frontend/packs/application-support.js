require.context("govuk-frontend/govuk/assets");

import { initAll as govUKFrontendInitAll } from "govuk-frontend";
import initApiTokenProviderAutocomplete from "./api-token-autocomplete";
import filter from "./components/paginated_filter";
import initCoursesAutocomplete from "./courses-autocomplete";
import "accessible-autocomplete/dist/accessible-autocomplete.min.css";
import "../styles/application-support.scss";

govUKFrontendInitAll();
initCoursesAutocomplete();
initApiTokenProviderAutocomplete();
filter();
