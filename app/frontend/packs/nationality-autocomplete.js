import accessibleAutocomplete from "accessible-autocomplete";

const initNationalityAutocomplete = () => {
  try {
    const nationalitySelects = [
      "#candidate-interface-personal-details-form-first-nationality-field",
      "#candidate-interface-personal-details-form-first-nationality-field-error",
      "#candidate-interface-personal-details-form-second-nationality-field",
      "#candidate-interface-personal-details-form-second-nationality-field-error"
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
