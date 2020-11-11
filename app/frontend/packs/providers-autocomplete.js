import accessibleAutocomplete from "accessible-autocomplete";

const initProvidersAutocomplete = () => {
  try {
    const id = "#pick-provider-form .govuk-select";
    const selectElement = document.querySelector(id);
    if (!selectElement) return;

    // Replace "Select a provider" with empty string
    selectElement.querySelector("[value='']").innerHTML = "";

    accessibleAutocomplete.enhanceSelectElement({
      selectElement,
      autoselect: false,
      confirmOnBlur: false,
      showAllValues: true
    });
  } catch (err) {
    console.error("Could not enhance providers select:", err);
  }
};

export default initProvidersAutocomplete;
