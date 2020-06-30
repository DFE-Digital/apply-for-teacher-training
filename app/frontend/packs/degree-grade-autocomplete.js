import accessibleAutocomplete from "accessible-autocomplete";

const initDegreeGradeAutocomplete = () => {
  try {
    const inputIds = [
      "candidate-interface-degree-grade-form-other-grade-field",
      "candidate-interface-degree-grade-form-other-grade-field-error"
    ];

    inputIds.forEach(inputId => {
      const input = document.getElementById(inputId);
      console.log(input);
      if (!input) return;

      const containerId = "degree-grade-autocomplete";
      const container = document.getElementById(containerId);
      console.log(container);
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
    console.error("Could not enhance degree grade input:", err);
  }
};

export default initDegreeGradeAutocomplete;
