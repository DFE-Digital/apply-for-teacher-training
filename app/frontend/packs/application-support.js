require.context("govuk-frontend/govuk/assets");

import { initAll as govUKFrontendInitAll } from "govuk-frontend";
import initApiTokenProviderAutocomplete from "./api-token-autocomplete";
import "../styles/application-support.scss";
import "accessible-autocomplete/dist/accessible-autocomplete.min.css";

govUKFrontendInitAll();
initApiTokenProviderAutocomplete();
