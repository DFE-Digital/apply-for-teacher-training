import accessibleAutocomplete from "accessible-autocomplete";

const initDegreeInstitutionCountryAutocomplete = () => {
  try {
    const inputIds = [
      "#candidate-interface-degree-institution-form-institution-country-field",
      "#candidate-interface-degree-institution-form-institution-country-field-error",
    ];

    inputIds.forEach(inputId => {
      const select = document.querySelector(inputId);

      if (!select) return;

      // Replace "Select a country" with empty string
      select.querySelector("[value='']").innerHTML = "";

      accessibleAutocomplete.enhanceSelectElement({
        selectElement: select,
        name: select.name,
        showAllValues: true,
        confirmOnBlur: false
      });
      select.name = "";
    });
  } catch (err) {
    console.error("Could not enhance degree institution country select:", err);
  }
};

export default initDegreeInstitutionCountryAutocomplete;
