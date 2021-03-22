const degreeGradeAutosuggestInputs = {
  inputIds: [
    "candidate-interface-degree-grade-form-other-grade-field",
    "candidate-interface-degree-grade-form-other-grade-field-error"
  ],
  containerId: "degree-grade-autosuggest"
};

const degreeInstitutionAutosuggestInputs = {
  inputIds: [
    "candidate-interface-degree-institution-form-institution-name-field",
    "candidate-interface-degree-institution-form-institution-name-field-error",
  ],
  containerId: 'degree-institution-autosuggest'
}

const degreeSubjectAutosuggestInputs = {
  inputIds: [
    "candidate-interface-degree-subject-form-subject-field",
    "candidate-interface-degree-subject-form-subject-field-error",
  ],
  containerId: "degree-subject-autosuggest"
}

const degreeTypeAutosuggestInputs = {
  inputIds: [
    "candidate-interface-degree-type-form-type-description-field",
    "candidate-interface-degree-type-form-type-description-field-error"
  ],
  containerId: "degree-type-autosuggest",
  templates: {
    inputTemplate: (result) => {
      return result ? result.split('|').pop() : '';
    },
    suggestionTemplate: (result) => {
      const descriptor = result.split('|');

      return descriptor.length === 1
        ? `<strong>${descriptor[0]}</strong>`
        : `<strong>${descriptor[0]}</strong> <span class="autocomplete__option--hint">${descriptor[1]}</span>`
    },
  }
}

const otherQualificationsSubjectAutosuggestInputs = {
  inputIds: [
    "candidate-interface-other-qualification-details-form-subject-field",
    "candidate-interface-other-qualification-details-form-subject-field-error",
  ],
  containerId: "subject-autosuggest-data"
}

const otherQualificationsGradeAutosuggestInputs = {
  inputIds: [
    "candidate-interface-other-qualification-details-form-grade-field",
    "candidate-interface-other-qualification-details-form-grade-field-error",
  ],
  containerId: "grade-autosuggest-data",
  styles: (containerId) => {
    const accessibleAutocompleteWrapper = document.querySelector(`#${containerId} .autocomplete__wrapper`);
    accessibleAutocompleteWrapper.classList.add("govuk-input--width-10");
  }
}

const otherQualificationsTypeAutosuggestInputs = {
  inputIds: [
    "candidate-interface-other-qualification-type-form-other-uk-qualification-type-field",
    "candidate-interface-other-qualification-type-form-other-uk-qualification-type-field-error",
  ],
  containerId: "other-uk-qualifications-autosuggest",
}

export const candidateAutosuggestInputs = [
  degreeGradeAutosuggestInputs,
  degreeInstitutionAutosuggestInputs,
  degreeTypeAutosuggestInputs,
  degreeSubjectAutosuggestInputs,
  otherQualificationsSubjectAutosuggestInputs,
  otherQualificationsGradeAutosuggestInputs,
  otherQualificationsTypeAutosuggestInputs
]
