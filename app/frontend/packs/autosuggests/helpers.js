import accessibleAutocomplete from 'accessible-autocomplete'

/**
 * Replace an input with an accessible autocomplete that has its own data source
 *
 * @param {object} input Element to be replaced by the autocomplete
 * @param {object} autosuggestContainer Element containing the autocomplete
 * @param {object} autosuggestOptions Options for accessibleAutocomplete
 */
export const accessibleAutosuggestFromSource = (input, autosuggestContainer, autosuggestOptions = {}) => {
  const source = JSON.parse(autosuggestContainer.dataset.source)

  // Move autocomplete to the form group containing the input to be replaced
  const inputFormGroup = autosuggestContainer.previousElementSibling
  if (inputFormGroup.contains(input)) {
    inputFormGroup.appendChild(autosuggestContainer)
  }

  accessibleAutocomplete({
    element: autosuggestContainer,
    id: input.id,
    name: input.name,
    source,
    showNoOptionsFound: false,
    defaultValue: input.value,
    ...autosuggestOptions
  })

  input.remove()
}
