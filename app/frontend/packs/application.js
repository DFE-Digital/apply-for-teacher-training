require.context("govuk-frontend/govuk/assets");
import { initAll as govUKFrontendInitAll } from "govuk-frontend";
import initNationalityAutocomplete from "./nationality-autocomplete";
import initCoursesAutocomplete from "./courses-autocomplete";

import "accessible-autocomplete/dist/accessible-autocomplete.min.css";
import "../styles/application.scss";
govUKFrontendInitAll();

initNationalityAutocomplete();
initCoursesAutocomplete();
