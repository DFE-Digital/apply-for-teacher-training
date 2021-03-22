const apiTokenAutocomplete = {
  inputIds: [
    '#vendor-api-token-provider-id-field.govuk-select'
  ],
  autocompleteId: 'api-token-autocomplete'
}

const countryAutocompleteInputs = {
  inputIds: [
    '#support-interface-application-forms-edit-address-details-form-country-field',
    '#support-interface-application-forms-edit-address-details-form-country-field-error'
  ],
  autocompleteId: 'country-autocomplete'
}

export const supportAutocompleteInputs = [
  apiTokenAutocomplete,
  countryAutocompleteInputs
]
