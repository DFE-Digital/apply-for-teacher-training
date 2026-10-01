import { initDfeAutocomplete } from './init-dfe-autocomplete'

describe('initDfeAutocomplete', () => {
  beforeEach(() => {
    document.body.innerHTML = `
      <div data-module="app-dfe-autocomplete" data-default-value="">
        <div class="govuk-form-group">
          <label class="govuk-label" for="subject-field">Subject</label>
          <select id="subject-field" name="form[subject]">
            <option value=""></option>
            <option value="Mathematics">Mathematics</option>
          </select>
        </div>
      </div>`
  })

  it('enhances the select with a raw attribute input', () => {
    initDfeAutocomplete()

    const input = document.querySelector('.autocomplete__input')
    expect(input).not.toBeNull()
    expect(input.name).toEqual('form[subject_raw]')
  })
})
