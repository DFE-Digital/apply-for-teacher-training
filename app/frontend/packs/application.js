require.context("govuk-frontend/govuk/assets");
import { initAll as govUKFrontendInitAll } from "govuk-frontend";
import "accessible-autocomplete/dist/accessible-autocomplete.min.css";
import accessibleAutocomplete from "accessible-autocomplete";

import "../styles/application.scss";
govUKFrontendInitAll();

try {
  const nationalitySelects = [
    "#candidate-interface-personal-details-form-first-nationality-field",
    "#candidate-interface-personal-details-form-second-nationality-field"
  ].forEach(id => {
    const nationalitySelect = document.querySelector(id);

    // Replace "Select a nationality" with empty string
    nationalitySelect.querySelector("[value='']").innerHTML = "";

    accessibleAutocomplete.enhanceSelectElement({
      selectElement: nationalitySelect
    });
  });
} catch (err) {
  console.error("Could not enhance nationality select:", err);
}
