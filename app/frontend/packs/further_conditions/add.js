import assignIndexBasedValues from './assignIndexBasedValues'
import { ADD_BUTTON_CSS_CLASS, ITEM_CSS_CLASS, ITEM_PLACEHOLDER_ID } from './constants'
import setupRemoveButtons from './remove'

const setupAddAnotherButton = () => {
  const addAnotherButton = getAddButton()
  if (addAnotherButton) {
    addAnotherButton.type = 'button'
    addAnotherButton.addEventListener('click', addFurtherCondition)
  }
}

const addFurtherCondition = () => {
  const items = document.getElementsByClassName(ITEM_CSS_CLASS)
  const newId = items.length
  const newElement = buildNewFurtherConditionField(newId)
  getAddButton().insertAdjacentElement('beforebegin', newElement)
  newElement.querySelector('textarea').focus()
}

const buildNewFurtherConditionField = (newId) => {
  const newElement = document.getElementById(ITEM_PLACEHOLDER_ID).cloneNode(true)
  assignIndexBasedValues(newElement, newId)
  setupRemoveButtons(newElement)
  return newElement
}

const getAddButton = () => {
  return document.querySelector(`.${ADD_BUTTON_CSS_CLASS}`)
}

export default setupAddAnotherButton
