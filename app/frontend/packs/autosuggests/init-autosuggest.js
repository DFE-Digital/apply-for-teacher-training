import {accessibleAutosuggestFromSource} from "./helpers";

export const initAutosuggest = ({inputIds, containerId, templates = {}, styles = () => {}}) => {

  console.log(templates)

  try {
    inputIds.forEach(inputId => {
      const input = document.getElementById(inputId);
      if (!input) return;

      const container = document.getElementById(containerId);
      if (!container) return;

      accessibleAutosuggestFromSource(
        input,
        container,
        {
          templates: {
            inputValue: templates.inputTemplate,
            suggestion: templates.suggestionTemplate,
          }
        }
      );

      styles(containerId);
    });
  } catch (err) {
    console.error(`Could not enhance ${containerId}:`, err);
  }
};
