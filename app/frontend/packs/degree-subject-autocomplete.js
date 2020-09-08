import { accessibleAutocompleteFromSource } from "./helpers.js";

const initDegreeSubjectAutocomplete = () => {
  try {
    const inputIds = [
      "candidate-interface-degree-subject-form-subject-field",
      "candidate-interface-degree-subject-form-subject-field-error",
    ];

    inputIds.forEach(inputId => {
      const input = document.getElementById(inputId);
      if (!input) return;

      const containerId = "degree-subject-autocomplete";
      const container = document.getElementById(containerId);
      if (!container) return;

      accessibleAutocompleteFromSource(input, container);
    });

  } catch (err) {
    console.error("Could not enhance degree subject input:", err);
  }
};

export default initDegreeSubjectAutocomplete;
