const countryAutocompleteInputs = {
  inputIds: [
    '#candidate-interface-contact-details-form-country-field',
    '#candidate-interface-contact-details-form-country-field-error',
    '#candidate-interface-degree-institution-form-institution-country-field',
    '#candidate-interface-degree-institution-form-institution-country-field-error',
    '#candidate-interface-gcse-institution-country-form-institution-country-field',
    '#candidate-interface-gcse-institution-country-form-institution-country-field-error',
    '#candidate-interface-other-qualification-details-form-institution-country-field',
    '#candidate-interface-other-qualification-form-institution-country-field-error'
  ],
  autocompleteId: 'country-autocomplete'
}

const nationalityAutocompleteInputs = {
  inputIds: [
    'candidate-interface-nationalities-form-first-nationality-field',
    'candidate-interface-nationalities-form-first-nationality-field-error',
    'candidate-interface-nationalities-form-second-nationality-field',
    'candidate-interface-nationalities-form-second-nationality-field-error',
    'candidate-interface-nationalities-form-other-nationality1-field',
    'candidate-interface-nationalities-form-other-nationality1-field-error',
    'candidate-interface-nationalities-form-other-nationality2-field',
    'candidate-interface-nationalities-form-other-nationality2-field-error',
    'candidate-interface-nationalities-form-other-nationality3-field',
    'candidate-interface-nationalities-form-other-nationality3-field-error'
  ],
  autocompleteId: 'nationality-autocomplete'
}

const providerAutocompleteInputs = {
  inputIds: [
    'candidate-interface-pick-provider-form-provider-id-field',
    'candidate-interface-pick-provider-form-provider-id-field-error'
  ],
  autocompleteId: 'provider-autocomplete'
}

const courseAutocompleteInputs = {
  inputIds: [
    'candidate-interface-pick-course-form-course-id-field',
    'candidate-interface-pick-course-form-course-id-field-error'
  ],
  autocompleteId: 'course-autocomplete'
}

export const candidateAutocompleteInputs = [
  countryAutocompleteInputs,
  nationalityAutocompleteInputs,
  providerAutocompleteInputs,
  courseAutocompleteInputs
]
