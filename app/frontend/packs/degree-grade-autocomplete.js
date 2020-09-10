import { accessibleAutocompleteFromSource } from "./helpers.js";

const initDegreeGradeAutocomplete = () => {
  try {
    const inputIds = [
      "candidate-interface-degree-grade-form-other-grade-field",
      "candidate-interface-degree-grade-form-other-grade-field-error"
    ];

    inputIds.forEach(inputId => {
      const input = document.getElementById(inputId);
      if (!input) return;

      const containerId = "degree-grade-autocomplete";
      const container = document.getElementById(containerId);
      if (!container) return;

      accessibleAutocompleteFromSource(input, container);
    });

  } catch (err) {
    console.error("Could not enhance degree grade input:", err);
  }
};

export default initDegreeGradeAutocomplete;
