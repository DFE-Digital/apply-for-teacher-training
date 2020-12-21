import accessibleAutocomplete from "accessible-autocomplete";

const initCountryAutocomplete = () => {
  try {
    const inputIds = [
      "#candidate-interface-contact-details-form-country-field",
      "#candidate-interface-contact-details-form-country-field-error",
      "#candidate-interface-degree-institution-form-institution-country-field",
      "#candidate-interface-degree-institution-form-institution-country-field-error",
      "#candidate-interface-gcse-institution-country-form-institution-country-field",
      "#candidate-interface-gcse-institution-country-form-institution-country-field-error",
      "#candidate-interface-other-qualification-details-form-institution-country-field",
      "#candidate-interface-other-qualification-form-institution-country-field-error",
    ];

    inputIds.forEach(id => {
      const selectElement = document.querySelector(id);
      if (!selectElement) return;

      // Replace "Select a country" with empty string
      selectElement.querySelector("[value='']").innerHTML = "";

      accessibleAutocomplete.enhanceSelectElement({
        selectElement,
        autoselect: false,
        confirmOnBlur: false,
        showAllValues: true
      });
    });
  } catch (err) {
    console.error("Could not enhance country select:", err);
  }
};

export default initCountryAutocomplete;
