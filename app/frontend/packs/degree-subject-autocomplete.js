import accessibleAutocomplete from "accessible-autocomplete";

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

      const sourceData = JSON.parse(container.dataset.source);

      accessibleAutocomplete({
        element: container,
        id: inputId,
        name: input.name,
        source: sourceData,
        showNoOptionsFound: true,
        defaultValue: input.value
      });

      input.remove();
    });

  } catch (err) {
    console.error("Could not enhance degree subject input:", err);
  }
};

export default initDegreeSubjectAutocomplete;
