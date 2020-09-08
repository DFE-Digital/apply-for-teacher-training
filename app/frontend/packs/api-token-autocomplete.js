import accessibleAutocomplete from "accessible-autocomplete";

const initApiTokenProviderAutocomplete = () => {
  try {
    const id = "#vendor-api-token-provider-id-field.govuk-select";
    const apiTokenProviderSelect = document.querySelector(id);

    if (!apiTokenProviderSelect) return;

    accessibleAutocomplete.enhanceSelectElement({
      selectElement: apiTokenProviderSelect,
      showAllValues: true,
      confirmOnBlur: false
    });
  } catch (err) {
    console.error("Could not enhance API token select:", err);
  }
};

export default initApiTokenProviderAutocomplete;
