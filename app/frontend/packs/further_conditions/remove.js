import assignIndexBasedValues from './assignIndexBasedValues'
import { CONDITIONS_HEADING_ID, ITEM_CSS_CLASS, REMOVE_BUTTON_CSS_CLASS } from './constants'
import updateAddButtonVisibility from './updateAddButtonVisibility'

const setupRemoveButtons = (element) => {
  const removeButtons = element.getElementsByClassName(REMOVE_BUTTON_CSS_CLASS)
  if (removeButtons.length) {
    [].forEach.call(removeButtons, setRemoveButtonListener)
  }
}

const setRemoveButtonListener = (button) => {
  button.type = 'button'
  button.addEventListener('click', removeFurtherCondition)
}

const removeFurtherCondition = (event) => {
  const elementToRemove = event.target.parentElement
  elementToRemove.parentNode.removeChild(elementToRemove)

  updateAttributesOfConditionFields()

  document.getElementById(CONDITIONS_HEADING_ID).focus()
  updateAddButtonVisibility()
}

const updateAttributesOfConditionFields = () => {
  const addConditionItems = document.getElementsByClassName(ITEM_CSS_CLASS)
  return [].forEach.call(addConditionItems, assignIndexBasedValues)
}

export default setupRemoveButtons
