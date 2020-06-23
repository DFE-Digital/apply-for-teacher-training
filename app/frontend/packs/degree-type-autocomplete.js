import accessibleAutocomplete from "accessible-autocomplete";

const initDegreeTypeAutocomplete = () => {
  try {
    const inputId = "degree-type";
    const input = document.getElementById(inputId);
    const containerId = "degree-type-autocomplete";
    const container = document.getElementById(containerId);
    const sourceData = JSON.parse(container.dataset.source);

    function inputTemplate(result) {
      if (result) {
        const descriptor = result.split('|');

        return descriptor[1]
      }
    }

    function suggestionTemplate(result) {
      const descriptor = result.split('|');

      if (descriptor[0]) {
        return `<strong>${descriptor[0]}</strong> <span class="autocomplete__option--hint">${descriptor[1]}</span>`
      }
      return `<strong>${descriptor[1]}</strong>`
    }

    if (!container) return;

    input.remove();

    accessibleAutocomplete({
      element: container,
      id: inputId,
      name: input.name,
      source: sourceData,
      showNoOptionsFound: true,
      templates: {
        inputValue: inputTemplate,
        suggestion: suggestionTemplate
      }
    });
  } catch (err) {
    console.error("Could not enhance degree type input:", err);
  }
};

export default initDegreeTypeAutocomplete;
