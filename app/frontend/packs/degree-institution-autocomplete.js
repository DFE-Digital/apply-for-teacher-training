import { accessibleAutocompleteFromSource } from "./helpers.js";

const initDegreeInstitutionAutocomplete = () => {
  try {
    const inputIds = [
      "candidate-interface-degree-institution-form-institution-name-field",
      "candidate-interface-degree-institution-form-institution-name-field-error",
    ];

    inputIds.forEach(inputId => {
      const input = document.getElementById(inputId);
      if (!input) return;

      const containerId = "degree-institution-autocomplete";
      const container = document.getElementById(containerId);
      if (!container) return;

      accessibleAutocompleteFromSource(input, container);
    });

  } catch (err) {
    console.error("Could not enhance degree institution input:", err);
  }
};

export default initDegreeInstitutionAutocomplete;
