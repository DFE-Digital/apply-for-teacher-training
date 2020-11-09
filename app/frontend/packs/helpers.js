import accessibleAutocomplete from "accessible-autocomplete";

/**
 * Replace an input with an accessible autocomplete that has its own data source
 *
 * @param {object} input Element to be replaced by the autocomplete
 * @param {object} autocompleteContainer Element containing the autocomplete
 * @param {object} autocompleteOptions Options for accessibleAutocomplete
 */
export const accessibleAutocompleteFromSource = (input, autocompleteContainer, autocompleteOptions = {}) => {
  const source = JSON.parse(autocompleteContainer.dataset.source);

  // Move autocomplete to the form group containing the input to be replaced
  const inputFormGroup = autocompleteContainer.previousElementSibling
  if (inputFormGroup.contains(input)) {
    inputFormGroup.appendChild(autocompleteContainer)
  }

  accessibleAutocomplete({
    element: autocompleteContainer,
    id: input.id,
    name: input.name,
    source,
    showNoOptionsFound: false,
    defaultValue: input.value,
    ...autocompleteOptions
  });

  input.remove();
}
