import { accessibleAutosuggestFromSource } from "./helpers.js";

const initDegreeInstitutionAutosuggest = () => {
  try {
    const inputIds = [
      "candidate-interface-degree-institution-form-institution-name-field",
      "candidate-interface-degree-institution-form-institution-name-field-error",
    ];

    inputIds.forEach(inputId => {
      const input = document.getElementById(inputId);
      if (!input) return;

      const containerId = "degree-institution-autosuggest";
      const container = document.getElementById(containerId);
      if (!container) return;

      accessibleAutosuggestFromSource(input, container);
    });

  } catch (err) {
    console.error("Could not enhance degree institution input:", err);
  }
};

export default initDegreeInstitutionAutosuggest;
