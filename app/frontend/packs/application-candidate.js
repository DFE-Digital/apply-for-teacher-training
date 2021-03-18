require.context("govuk-frontend/govuk/assets");

import { initAll as govUKFrontendInitAll } from "govuk-frontend";
import initWarnOnUnsavedChanges from "./warn-on-unsaved-changes";
import {autocompleteInputs} from "./autocompletes/autocomplete-inputs";
import {autosuggestInputs} from "./autosuggests/autosuggest-inputs";
import {initAutocomplete} from "./autocompletes/init-autocomplete";
import {initAutosuggest} from "./autosuggests/init-autosuggest";
import nationalitiesComponent from "./nationalities-component";
import initBackLinks from "./app-back-link";
import "accessible-autocomplete/dist/accessible-autocomplete.min.css";
import "../styles/application-candidate.scss";

govUKFrontendInitAll();

autocompleteInputs.forEach((autocompleteInput) => {
  initAutocomplete(autocompleteInput)
});

autosuggestInputs.forEach((autoSuggestInput) => {
  initAutosuggest(autoSuggestInput)
})

initWarnOnUnsavedChanges();
nationalitiesComponent();
initBackLinks();
