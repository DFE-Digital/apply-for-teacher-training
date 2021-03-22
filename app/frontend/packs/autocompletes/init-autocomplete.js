import accessibleAutocomplete from "accessible-autocomplete";

export const initAutocomplete = ({inputIds, autocompleteId}) => {
  try {
    inputIds.forEach(id => {
      const selectElement = document.getElementById(id);

      if (!selectElement) return;

      // Replace "Select a ..." with empty string
      selectElement.querySelector("[value='']").innerHTML = "";

      accessibleAutocomplete.enhanceSelectElement({
        selectElement,
        autoselect: false,
        confirmOnBlur: false,
        showAllValues: true
      });
    });
  } catch (err) {
    console.error(`Could not enhance ${autocompleteId}`, err);
  }
};
