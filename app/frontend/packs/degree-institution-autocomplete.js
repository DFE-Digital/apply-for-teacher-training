import accessibleAutocomplete from "accessible-autocomplete";

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

      // Move autocomplete to the form group containing the input to be replaced
      const inputFormGroup = container.previousElementSibling
      if (inputFormGroup.contains(input)) {
        inputFormGroup.appendChild(container)
      }

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
    console.error("Could not enhance degree institution input:", err);
  }
};

export default initDegreeInstitutionAutocomplete;
