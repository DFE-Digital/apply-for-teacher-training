import { initAutocomplete } from './init-autocomplete'

describe('initAutocomplete', () => {
  const autocompleteInputs = {
    inputIds: ['form-field-id'],
    autocompleteId: 'an-autocomplete'
  }

  beforeEach(() => {
    document.body.innerHTML = `
        <div id="outer-container">
          <label for="${autocompleteInputs.inputIds[0]}">Enter something</label>
          <select id="${autocompleteInputs.inputIds[0]}">
            <option value>Select a option</option>
            <option value="A">A</option>
            <option value="B">B</option>
            <option value="C">C</option>
          </select>
        </div>
      `

    initAutocomplete(autocompleteInputs)
  })

  it('should instantiate an autocomplete', () => {
    expect(document.querySelector('#outer-container')).toMatchSnapshot()
  })
})
