const nationalitiesComponent = () => {
  const secondSelectEl = document.querySelectorAll(
    '#candidate-interface-nationalities-form-other-nationality2-field, \
    #candidate-interface-nationalities-form-other-nationality2-field-select'
  )
  if (!secondSelectEl) return

  const thirdSelectEl = document.querySelectorAll(
    '#candidate-interface-nationalities-form-other-nationality3-field, \
    #candidate-interface-nationalities-form-other-nationality3-field-select'
  )

  const secondFormLabel = document.querySelector(
    '[for=candidate-interface-nationalities-form-other-nationality2-field]'
  )
  const thirdFormLabel = document.querySelector(
    '[for=candidate-interface-nationalities-form-other-nationality3-field]'
  )

  let addNationalityButton = null

  if (secondFormLabel && thirdFormLabel) {
    addRemoveLink(secondFormLabel, secondSelectEl)

    addRemoveLink(thirdFormLabel, thirdSelectEl)

    addAddNationalityButton(
      '#candidate-interface-nationalities-form-nationalities-other-conditional'
    )

    hideSection(secondSelectEl, secondFormLabel)

    hideSection(thirdSelectEl, thirdFormLabel)
  }

  function addRemoveLink (labelEl, selectEl) {
    const parentEl = labelEl.parentElement

    const removeLink = document.createElement('a')
    removeLink.innerHTML = 'Remove'
    removeLink.classList.add('govuk-link', 'app-nationality__remove-link')

    // This has to be a link and not a button as the govuk-link class requires an
    // href to apply its styling
    removeLink.href = '#'
    parentEl.insertBefore(removeLink, labelEl)

    if (labelEl === secondFormLabel) {
      addNthNationalityHiddenSpan(removeLink, 'Second')
    } else {
      addNthNationalityHiddenSpan(removeLink, 'Third')
    }

    removeLink.addEventListener('click', function (event) {
      event.preventDefault()
      handleRemoveLinkClick(labelEl, selectEl)
    })
  }

  function addNthNationalityHiddenSpan (removeLink, nthNationality) {
    const nthNationalitySpan = document.createElement('span')
    nthNationalitySpan.classList.add('govuk-visually-hidden')
    nthNationalitySpan.innerHTML = ` ${nthNationality.toLowerCase()} nationality`
    removeLink.appendChild(nthNationalitySpan)
  }

  function addAddNationalityButton (parentSelector) {
    const parent = document.querySelector(parentSelector)
    addNationalityButton = document.createElement('button')
    addNationalityButton.innerHTML = 'Add another nationality'
    addNationalityButton.id = 'add-nationality-button'
    addNationalityButton.classList.add(
      'govuk-button',
      'govuk-button--secondary'
    )
    parent.appendChild(addNationalityButton)

    if (Array(secondSelectEl).every(elementIsNotBlank) && Array.from(thirdSelectEl).every(elementIsNotBlank)) {
      addNationalityButton.style.display = 'none'
    }

    addNationalityButton.addEventListener('click', function (event) {
      event.preventDefault()
      handleAddNationalityClick()
    })
  }

  function hideSection (selectEl, labelEl) {
    if (Array.from(selectEl).every(elementIsBlank)) {
      labelEl.parentElement.style.display = 'none'
    }
  }

  function handleRemoveLinkClick (labelEl, selectEl) {
    addNationalityButton.style.display = ''
    labelEl.parentElement.style.display = 'none'

    for (const el of selectEl) {
      el.value = ''
    }
  }

  function handleAddNationalityClick () {
    if (
      secondFormLabel.parentElement.style.display === 'none' &&
      thirdFormLabel.parentElement.style.display === 'none'
    ) {
      secondFormLabel.parentElement.style.display = ''
    } else if (secondFormLabel.parentElement.style.display === 'none') {
      secondFormLabel.parentElement.style.display = ''
      addNationalityButton.style.display = 'none'
    } else {
      thirdFormLabel.parentElement.style.display = ''
      addNationalityButton.style.display = 'none'
    }
  }

  function elementIsBlank (el) {
    return el.value === ''
  }

  function elementIsNotBlank (el) {
    return el.value !== ''
  }
}

export default nationalitiesComponent
