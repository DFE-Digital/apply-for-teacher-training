import { accessibleAutocompleteFromSource } from "./helpers.js";

const initOtherQualificationsSubjectAutocomplete = () => {
  try {
    const inputIds = [
      "candidate-interface-other-qualification-details-form-subject-field",
      "candidate-interface-other-qualification-details-form-subject-field-error",
    ];

    inputIds.forEach(inputId => {
      const input = document.getElementById(inputId);
      if (!input) return;

      const containerId = "subject-autocomplete-data";
      const container = document.getElementById(containerId);
      if (!container) return;

      accessibleAutocompleteFromSource(input, container);
    });

  } catch (err) {
    console.error("Could not enhance subject input:", err);
  }
};

export default initOtherQualificationsSubjectAutocomplete;
