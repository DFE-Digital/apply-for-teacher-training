import { initAutosuggest } from './init-autosuggest'

describe('initAutoSuggest', () => {
  const autosuggestInputs = {
    inputIds: ['form-field-id'],
    containerId: 'autosuggest-containerId',
    styles: (containerId) => {
      const accessibleAutocompleteWrapper = document.querySelector(`#${containerId} .autocomplete__wrapper`)
      accessibleAutocompleteWrapper.classList.add('govuk-input--width-10')
    },
    templates: {
      inputTemplate: (result) => {
        return result ? result.split('|').pop() : ''
      },
      suggestionTemplate: (result) => {
        const descriptor = result.split('|')

        return descriptor.length === 1
          ? `<strong>${descriptor[0]}</strong>`
          : `<strong>${descriptor[0]}</strong><span class="autocomplete__option--hint">${descriptor[1]}</span>`
      }
    }
  }

  beforeEach(() => {
    document.body.innerHTML = `
        <div id="outer-container">
            <div>
              <label for="${autosuggestInputs.inputIds[0]}">Enter something</label>
              <input id="${autosuggestInputs.inputIds[0]}">
            </div>
            <div id="${autosuggestInputs.containerId}" data-source='["A", "B", "C"]'></div>
        </div>
      `

    initAutosuggest(autosuggestInputs)
  })

  it('should instantiate an autosuggest', () => {
    expect(document.querySelector('#outer-container')).toMatchSnapshot()
  })
})
