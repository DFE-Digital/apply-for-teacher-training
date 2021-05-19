import { ADD_BUTTON_CSS_CLASS, ITEM_CSS_CLASS } from './constants'

const FALLBACK_MAX_FURTHER_CONDITIONS = 18

const updateAddButtonVisibility = () => {
  const addButton = document.querySelector(`.${ADD_BUTTON_CSS_CLASS}`)

  const maxFurtherConditions = addButton.dataset.maxConditions || FALLBACK_MAX_FURTHER_CONDITIONS

  const items = document.getElementsByClassName(ITEM_CSS_CLASS)
  if (items.length >= maxFurtherConditions) {
    addButton.style.display = 'none'
  } else {
    addButton.style.display = 'block'
  }
}

export default updateAddButtonVisibility
