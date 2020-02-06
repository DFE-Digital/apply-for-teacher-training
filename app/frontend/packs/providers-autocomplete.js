import accessibleAutocomplete from "accessible-autocomplete";

const initProvidersAutocomplete = () => {
  try {
    [
      "#candidate-interface-pick-provider-form-code-field",
      "#candidate-interface-pick-provider-form-code-field-error"
    ].forEach(id => {
      const providersSelect = document.querySelector(id);

      if (!providersSelect) return;

      // Replace "Select a provider" with empty string
      providersSelect.querySelector("[value='']").innerHTML = "";

      accessibleAutocomplete.enhanceSelectElement({
        selectElement: providersSelect,
        showAllValues: true,
        confirmOnBlur: false
      });
    });
  } catch (err) {
    console.error("Could not enhance providers select:", err);
  }
};

export default initProvidersAutocomplete;
