require.context("govuk-frontend/govuk/assets");

import { initAll as govUKFrontendInitAll } from "govuk-frontend";
import initApiTokenProviderAutocomplete from "./autocompletes/api-token-autocomplete";
import "../styles/application-support.scss";
import filter from "./components/paginated_filter";
import "accessible-autocomplete/dist/accessible-autocomplete.min.css";
import initCountryAutocomplete from "./autocompletes/country-autocomplete";

govUKFrontendInitAll();
initApiTokenProviderAutocomplete();
filter();
initCountryAutocomplete();
