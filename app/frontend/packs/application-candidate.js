require.context("govuk-frontend/govuk/assets");

import { initAll as govUKFrontendInitAll } from "govuk-frontend";
import initWarnOnUnsavedChanges from "./warn-on-unsaved-changes";
import {initAutosuggest} from "./autosuggests/init-autosuggest";
import {autocompleteInputs} from "./autocompletes/autocomplete-inputs";
import {initAutocomplete} from "./autocompletes/init-autocomplete";
import {
  degreeGradeAutosuggestInputs,
  degreeInstitutionAutosuggestInputs,
  degreeSubjectAutosuggestInputs,
  degreeTypeAutosuggestInputs,
  otherQualificationsGradeAutosuggestInputs,
  otherQualificationsSubjectAutosuggestInputs,
  otherQualificationsTypeAutosuggestInputs
} from "./autosuggests/autosuggest-inputs";
import nationalitiesComponent from "./nationalities-component";
import initBackLinks from "./app-back-link";
import "accessible-autocomplete/dist/accessible-autocomplete.min.css";
import "../styles/application-candidate.scss";

govUKFrontendInitAll();

autocompleteInputs.forEach((autocompleteInput) => {
  initAutocomplete(autocompleteInput)
});

initAutosuggest(degreeGradeAutosuggestInputs);
initAutosuggest(degreeInstitutionAutosuggestInputs);
initAutosuggest(degreeSubjectAutosuggestInputs);
initAutosuggest(degreeTypeAutosuggestInputs);
initAutosuggest(otherQualificationsGradeAutosuggestInputs);
initAutosuggest(otherQualificationsTypeAutosuggestInputs);
initAutosuggest(otherQualificationsSubjectAutosuggestInputs);

initWarnOnUnsavedChanges();
nationalitiesComponent();
initBackLinks();
