const otherQualificationsSubjectAutosuggestInputs = {
  inputIds: [
    'candidate-interface-other-qualification-details-form-subject-field',
    'candidate-interface-other-qualification-details-form-subject-field-error'
  ],
  containerId: 'subject-autosuggest-data'
}

const otherQualificationsGradeAutosuggestInputs = {
  inputIds: [
    'candidate-interface-other-qualification-details-form-grade-field',
    'candidate-interface-other-qualification-details-form-grade-field-error'
  ],
  containerId: 'grade-autosuggest-data',
  styles: (containerId) => {
    const accessibleAutocompleteWrapper = document.querySelector(`#${containerId} .autocomplete__wrapper`)
    accessibleAutocompleteWrapper.classList.add('govuk-input--width-10')
  }
}

const otherQualificationsTypeAutosuggestInputs = {
  inputIds: [
    'candidate-interface-other-qualification-type-form-other-uk-qualification-type-field',
    'candidate-interface-other-qualification-type-form-other-uk-qualification-type-field-error'
  ],
  containerId: 'other-uk-qualifications-autosuggest'
}

export const candidateAutosuggestInputs = [
  otherQualificationsSubjectAutosuggestInputs,
  otherQualificationsGradeAutosuggestInputs,
  otherQualificationsTypeAutosuggestInputs
]
