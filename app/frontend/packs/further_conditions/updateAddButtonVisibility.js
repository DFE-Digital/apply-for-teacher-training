import { ADD_BUTTON_CSS_CLASS, ITEM_CSS_CLASS } from './constants'

const MAX_FURTHER_CONDITIONS = 18

const updateAddButtonVisibility = () => {
  const addButton = document.querySelector(`.${ADD_BUTTON_CSS_CLASS}`)
  const items = document.getElementsByClassName(ITEM_CSS_CLASS)
  if (items.length >= MAX_FURTHER_CONDITIONS) {
    addButton.style.display = 'none'
  } else {
    addButton.style.display = 'block'
  }
}

export default updateAddButtonVisibility
