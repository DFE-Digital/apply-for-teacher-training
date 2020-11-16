import { accessibleAutocompleteFromSource } from "./helpers.js";

const initOtherQualificationsGradeAutocomplete = () => {
  try {
    const inputIds = [
      "candidate-interface-other-qualification-wizard-grade-field",
      "candidate-interface-other-qualification-wizard-grade-field-error",
    ];

    inputIds.forEach(inputId => {
      const input = document.getElementById(inputId);
      if (!input) return;

      const containerId = "grade-autocomplete-data";
      const container = document.getElementById(containerId);
      if (!container) return;

      accessibleAutocompleteFromSource(input, container);
    });

  } catch (err) {
    console.error("Could not enhance grade input:", err);
  }
};

export default initOtherQualificationsGradeAutocomplete;
