require.context("govuk-frontend/govuk/assets");

import { initAll as govUKFrontendInitAll } from "govuk-frontend";
import initNationalityAutocomplete from "./nationality-autocomplete";
import initCoursesAutocomplete from "./courses-autocomplete";
import initProvidersAutocomplete from "./providers-autocomplete";
import initDegreeSubjectAutocomplete from "./degree-subject-autocomplete";
import initDegreeTypeAutocomplete from "./degree-type-autocomplete";
import initWarnOnUnsavedChanges from "./warn-on-unsaved-changes";
import providerFilter from "./provider-filter";

import "accessible-autocomplete/dist/accessible-autocomplete.min.css";
import "../styles/application.scss";
govUKFrontendInitAll();

initNationalityAutocomplete();
initProvidersAutocomplete();
initCoursesAutocomplete();
initDegreeSubjectAutocomplete();
initDegreeTypeAutocomplete();
initWarnOnUnsavedChanges();
providerFilter();
