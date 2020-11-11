import accessibleAutocomplete from "accessible-autocomplete";

const initApiTokenProviderAutocomplete = () => {
  try {
    const id = "#vendor-api-token-provider-id-field.govuk-select";
    const selectElement = document.querySelector(id);
    if (!selectElement) return;

    accessibleAutocomplete.enhanceSelectElement({
      selectElement,
      autoselect: false,
      confirmOnBlur: false,
      showAllValues: true
    });
  } catch (err) {
    console.error("Could not enhance API token select:", err);
  }
};

export default initApiTokenProviderAutocomplete;
