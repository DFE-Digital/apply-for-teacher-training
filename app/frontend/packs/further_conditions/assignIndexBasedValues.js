import { ITEM_CSS_CLASS, REMOVE_BUTTON_CSS_CLASS } from './constants'

const assignIndexBasedValues = (element, index) => {
  element.className = ITEM_CSS_CLASS
  element.removeAttribute('id')

  setHiddenIdInputProperties(element, index)
  setTextAreaProperties(element, index)
  setLabelProperties(element, index)
  setRemoveButtonProperties(element, index)
}

const setHiddenIdInputProperties = (element, index) => {
  const idInput = element.querySelector('input')
  setInputProperties(idInput, index)
}

const setTextAreaProperties = (element, index) => {
  const textArea = element.querySelector('textarea')
  setInputProperties(textArea, index)
}

const setInputProperties = (inputElement, index) => {
  replaceExistingAttribute(inputElement, 'id', index)
  replaceExistingAttribute(inputElement, 'name', index)
  inputElement.removeAttribute('disabled')
}

const setLabelProperties = (element, index) => {
  const label = element.querySelector('label')
  replaceExistingAttribute(label, 'for', index)
  label.innerHTML = replacedText(label.innerHTML, index + 1)
}

const setRemoveButtonProperties = (element, index) => {
  const removeButton = element.querySelector(`.${REMOVE_BUTTON_CSS_CLASS}`)
  replaceExistingAttribute(removeButton, 'value', index)
  const hiddenText = removeButton.querySelector('.govuk-visually-hidden')
  hiddenText.innerHTML = replacedText(hiddenText.innerHTML, index + 1)
}

const replaceExistingAttribute = (element, attribute, replaceValue) => {
  const placeholderValue = element.getAttribute(attribute)
  const newValue = replacedText(placeholderValue, replaceValue)
  element.setAttribute(attribute, newValue)
}

const replacedText = (oldString, replaceValue) => {
  return oldString.replace(/\d+/, replaceValue).replace('placeholder', replaceValue)
}

export default assignIndexBasedValues
