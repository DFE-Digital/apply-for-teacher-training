import accessibleAutocomplete from "accessible-autocomplete";

const initNationalityAutocomplete = () => {
  try {
    const nationalitySelects = [
      "#candidate-interface-nationalities-form-first-nationality-field",
      "#candidate-interface-nationalities-form-first-nationality-field-error",
      "#candidate-interface-nationalities-form-second-nationality-field",
      "#candidate-interface-nationalities-form-second-nationality-field-error",
      "#candidate-interface-nationalities-form-other-nationality1-field",
      "#candidate-interface-nationalities-form-other-nationality1-field-error",
      "#candidate-interface-nationalities-form-other-nationality2-field",
      "#candidate-interface-nationalities-form-other-nationality2-field-error",
      "#candidate-interface-nationalities-form-other-nationality3-field",
      "#candidate-interface-nationalities-form-other-nationality3-field-error",
      "#candidate-interface-contact-details-form-country-field",
      "#candidate-interface-contact-details-form-country-field-error",
      "#candidate-interface-gcse-institution-country-form-institution-country-field",
      "#candidate-interface-gcse-institution-country-form-institution-country-field-error",
    ].forEach(id => {
      const nationalitySelect = document.querySelector(id);

      if (!nationalitySelect) return;

      // Replace "Select a nationality" with empty string
      nationalitySelect.querySelector("[value='']").innerHTML = "";

      accessibleAutocomplete.enhanceSelectElement({
        selectElement: nationalitySelect,
        name: nationalitySelect.name,
        showAllValues: true,
        confirmOnBlur: false
      });
      nationalitySelect.name = "";
    });
  } catch (err) {
    console.error("Could not enhance nationality select:", err);
  }
};

export default initNationalityAutocomplete;
