import accessibleAutocomplete from "accessible-autocomplete";

const initNationalityAutocomplete = () => {
  try {
    const inputIds = [
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
    ];

    inputIds.forEach(id => {
      const selectElement = document.querySelector(id);
      if (!selectElement) return;

      const selectValue = selectElement.querySelector("[value='']");
      if(!selectValue) return;

      // Replace "Select a nationality" with empty string
      selectElement.querySelector("[value='']").innerHTML = "";

      accessibleAutocomplete.enhanceSelectElement({
        selectElement,
        name: selectElement.name,
        autoselect: false,
        confirmOnBlur: false,
        showAllValues: true
      });

      selectElement.name = "";
    });
  } catch (err) {
    console.error("Could not enhance nationality select:", err);
  }
};

export default initNationalityAutocomplete;
