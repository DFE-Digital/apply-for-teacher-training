import accessibleAutocomplete from "accessible-autocomplete";

const initCountryAutocomplete = () => {
  try {
    const inputIds = [
      "#candidate-interface-contact-details-form-country-field",
      "#candidate-interface-contact-details-form-country-field-error",
      "#candidate-interface-degree-institution-form-institution-country-field",
      "#candidate-interface-degree-institution-form-institution-country-field-error",
    ];

    inputIds.forEach(inputId => {
      const select = document.querySelector(inputId);

      if (!select) { return; }

      // Replace "Select a country" with empty string
      select.querySelector("[value='']").innerHTML = "";

      accessibleAutocomplete.enhanceSelectElement({
        selectElement: select,
        showAllValues: true,
        confirmOnBlur: false
      });
    });
  } catch (err) {
    console.error("Could not enhance degree institution country select:", err);
  }
};

export default initCountryAutocomplete;
