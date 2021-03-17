

require.context("govuk-frontend/govuk/assets");

import { initAll as govUKFrontendInitAll } from "govuk-frontend";
import initWarnOnUnsavedChanges from "./warn-on-unsaved-changes";
import {initAutosuggest} from "./autosuggests/init-autosuggest";
import {
  degreeGradeAutosuggestionInputs,
  degreeInstitutionAutosuggestInputs,
  degreeSubjectAutosuggestInputs,
  degreeTypeAutosuggestInputs,
  otherQualificationsGradeAutosuggestInputs,
  otherQualificationsSubjectAutosuggestInputs,
  otherQualificationsTypeAutosuggestInputs
} from "./autosuggests/autosuggest-inputs";
import initNationalityAutocomplete from "./autocompletes/nationality-autocomplete";
import initProvidersAutocomplete from "./autocompletes/providers-autocomplete";
import initCoursesAutocomplete from "./autocompletes/courses-autocomplete";
import initCountryAutocomplete from "./autocompletes/country-autocomplete";
import nationalitiesComponent from "./nationalities-component";
import initBackLinks from "./app-back-link";
import "accessible-autocomplete/dist/accessible-autocomplete.min.css";
import "../styles/application-candidate.scss";

govUKFrontendInitAll();

initNationalityAutocomplete();
initProvidersAutocomplete();
initCoursesAutocomplete();
initCountryAutocomplete();

initAutosuggest(degreeGradeAutosuggestionInputs);
initAutosuggest(degreeInstitutionAutosuggestInputs);
initAutosuggest(degreeSubjectAutosuggestInputs);
initAutosuggest(degreeTypeAutosuggestInputs);
initAutosuggest(otherQualificationsGradeAutosuggestInputs);
initAutosuggest(otherQualificationsTypeAutosuggestInputs);
initAutosuggest(otherQualificationsSubjectAutosuggestInputs);

initWarnOnUnsavedChanges();
nationalitiesComponent();
initBackLinks();
