import { accessibleAutosuggestFromSource } from "./helpers.js";

const initOtherQualificationsSubjectAutosuggest = () => {
  try {
    const inputIds = [
      "candidate-interface-other-qualification-details-form-subject-field",
      "candidate-interface-other-qualification-details-form-subject-field-error",
    ];

    inputIds.forEach(inputId => {
      const input = document.getElementById(inputId);
      if (!input) return;

      const containerId = "subject-autosuggest-data";
      const container = document.getElementById(containerId);
      if (!container) return;

      accessibleAutosuggestFromSource(input, container);
    });

  } catch (err) {
    console.error("Could not enhance subject input:", err);
  }
};

export default initOtherQualificationsSubjectAutosuggest;
