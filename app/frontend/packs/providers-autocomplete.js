import accessibleAutocomplete from "accessible-autocomplete";

const initProvidersAutocomplete = () => {
  try {
    const id = "#pick-provider-form .govuk-select";
    const providersSelect = document.querySelector(id);

    if (!providersSelect) return;

    // Replace "Select a provider" with empty string
    providersSelect.querySelector("[value='']").innerHTML = "";

    accessibleAutocomplete.enhanceSelectElement({
      selectElement: providersSelect,
      showAllValues: true,
      confirmOnBlur: false
    });
  } catch (err) {
    console.error("Could not enhance providers select:", err);
  }
};

export default initProvidersAutocomplete;
