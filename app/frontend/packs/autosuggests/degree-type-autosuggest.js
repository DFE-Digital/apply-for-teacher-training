import { accessibleAutosuggestFromSource } from "./helpers.js";

const initDegreeTypeAutosuggest = () => {
  function inputTemplate(result) {
    return result ? result.split('|').pop() : '';
  }

  function suggestionTemplate(result) {
    const descriptor = result.split('|');

    return descriptor.length === 1
      ? `<strong>${descriptor[0]}</strong>`
      : `<strong>${descriptor[0]}</strong> <span class="autocomplete__option--hint">${descriptor[1]}</span>`
  }

  try {
    const inputIds = [
      "candidate-interface-degree-type-form-type-description-field",
      "candidate-interface-degree-type-form-type-description-field-error"
    ];

    inputIds.forEach(inputId => {
      const input = document.getElementById(inputId);
      if (!input) return;

      const containerId = "degree-type-autosuggest";
      const container = document.getElementById(containerId);
      if (!container) return;

      accessibleAutosuggestFromSource(input, container, {
        templates: {
          inputValue: inputTemplate,
          suggestion: suggestionTemplate
        }
      });
    });

  } catch (err) {
    console.error("Could not enhance degree type input:", err);
  }
};

export default initDegreeTypeAutosuggest;
