import { accessibleAutosuggestFromSource } from "./helpers.js";

const initOtherQualificationsGradeAutosuggest = () => {
  try {
    const inputIds = [
      "candidate-interface-other-qualification-details-form-grade-field",
      "candidate-interface-other-qualification-details-form-grade-field-error",
    ];

    inputIds.forEach(inputId => {
      const input = document.getElementById(inputId);
      if (!input) return;

      const containerId = "grade-autosuggest-data";
      const container = document.getElementById(containerId);
      if (!container) return;

      accessibleAutosuggestFromSource(input, container);

      const accessibleAutocompleteWrapper = document.querySelector(`#${containerId} .autocomplete__wrapper`);
      accessibleAutocompleteWrapper.classList.add("govuk-input--width-10");

    });

  } catch (err) {
    console.error("Could not enhance grade input:", err);
  }
};

export default initOtherQualificationsGradeAutosuggest;
