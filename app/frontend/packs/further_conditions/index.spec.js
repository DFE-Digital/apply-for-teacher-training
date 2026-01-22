import initAddFurtherConditions from '.'

const setupBodyWithConditions = (count) => {
  document.body.innerHTML = `
    <fieldset>
      <legend id="further-conditions-heading" tabindex="-1">Further conditions</legend>
      <div id="add-another-item-placeholder">
        <input disabled="disabled" type="hidden" name="provider_interface_offer_wizard[further_conditions][placeholder][condition_id]" id="provider_interface_offer_wizard_further_conditions_placeholder_condition_id">
        <div>
          <label for="provider-interface-offer-wizard-further-conditions-placeholder-text-field">Condition placeholder</label>
          <textarea id="provider-interface-offer-wizard-further-conditions-placeholder-text-field" disabled="disabled" name="provider_interface_offer_wizard[further_conditions][placeholder][text]"></textarea>
        </div>
        <button name="remove_condition" type="submit" value="placeholder" class="app-add-condition__remove-button">
          Remove <span class="govuk-visually-hidden"> condition placeholder</span>
        </button>
      </div>
      ${conditionFieldList(count)}
      <button name="commit" type="submit" value="add_another_condition" class="app-add-condition__add-button">
        Add another condition
      </button>
    </fieldset>
  `
}

const conditionFieldList = (count) => {
  let result = ''
  for (let i = 0; i < count; i++) {
    result += conditionFieldWithId(i)
  }
  return result
}

const conditionFieldWithId = (id) => {
  return `
    <div class="app-add-condition__item" >
      <input disabled="disabled" type="hidden" name="provider_interface_offer_wizard[further_conditions][${id}][condition_id]" id="provider_interface_offer_wizard_further_conditions_${id}_condition_id">
      <div>
        <label for="provider-interface-offer-wizard-further-conditions-${id}-text-field">Condition ${id + 1}</label>
        <textarea id="provider-interface-offer-wizard-further-conditions-${id}-text-field" name="provider_interface_offer_wizard[further_conditions][${id}][text]"></textarea>
      </div>
      <button name="remove_condition" type="submit" value="${id}" class="app-add-condition__remove-button">
        Remove <span class="govuk-visually-hidden"> condition ${id + 1}</span>
      </button>
    </div>
  `
}

describe('initAddFurtherConditions', () => {
  it('changes button types from submit to button', () => {
    setupBodyWithConditions(1)
    initAddFurtherConditions()

    expect(document.querySelector('.app-add-condition__add-button').type).toEqual('button')
    expect(document.querySelector('.app-add-condition__remove-button').type).toEqual('button')
  })

  it('should add a condition field when the add button is clicked', () => {
    setupBodyWithConditions(0)
    initAddFurtherConditions()
    expect(document.querySelectorAll('.app-add-condition__item').length).toEqual(0)

    document.querySelector('.app-add-condition__add-button').click()

    expect(document.querySelectorAll('.app-add-condition__item').length).toEqual(1)
  })

  it('should hide the add button if there are 18 conditions', () => {
    setupBodyWithConditions(17)
    initAddFurtherConditions()

    document.querySelector('.app-add-condition__add-button').click()

    expect(document.querySelector('.app-add-condition__add-button').style.display).toEqual('none')
  })

  it('should unhide the add button if there are fewer than 18 conditions', () => {
    setupBodyWithConditions(17)
    initAddFurtherConditions()

    document.querySelector('.app-add-condition__add-button').click()
    document.querySelector('.app-add-condition__remove-button[value="1"]').click()

    expect(document.querySelector('.app-add-condition__add-button').style.display).toEqual('block')
  })
})
