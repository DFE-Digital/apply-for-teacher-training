import setupAddAnotherButton from './add'
import setupRemoveButtons from './remove'

const initAddFurtherConditions = () => {
  setupAddAnotherButton()
  setupRemoveButtons(document)
}

export default initAddFurtherConditions
