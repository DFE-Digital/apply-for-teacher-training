import { accessibleAutocompleteFromSource } from "./helpers.js";

const initOtherUKQualificationsAutocomplete = () => {
  try {
    const inputIds = [
      "candidate-interface-other-qualification-type-form-other-uk-qualification-type-field",
      "candidate-interface-other-qualification-type-form-other-uk-qualification-type-field-error"
    ];

    inputIds.forEach(inputId => {
      const input = document.getElementById(inputId);
      if (!input) return;

      const containerId = "other-uk-qualifications-autocomplete";
      const container = document.getElementById(containerId);
      if (!container) return;

      accessibleAutocompleteFromSource(input, container);
    });

  } catch (err) {
    console.error("Could not enhance qualification type input:", err);
  }
};

export default initOtherUKQualificationsAutocomplete;
