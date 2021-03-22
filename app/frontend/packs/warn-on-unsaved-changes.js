const getCompleteSectionCheckbox = () => {
  const $labels = document.querySelectorAll('.govuk-checkboxes__label')
  const text = 'I have completed this section'

  return [].filter.call($labels, ($label) => $label.innerHTML === text)[0]
}

const getTextArea = () => {
  return document.querySelector('.govuk-textarea')
}

const getFirstEnhanceableForm = () => {
  const $element = getTextArea() || getCompleteSectionCheckbox()
  if (!$element) return null

  return $element.form
}

const initWarnOnUnsavedChanges = ($form = getFirstEnhanceableForm()) => {
  if (!$form) return

  let hasChanged = false

  $form.addEventListener('submit', () => {
    window.onbeforeunload = null
  })

  $form.addEventListener('change', () => {
    hasChanged = true
  })

  window.onbeforeunload = (event) => {
    if (!hasChanged) return

    // Used to handle browsers that use legacy onbeforeunload
    // https://developer.mozilla.org/en-US/docs/Web/API/Window/beforeunload_event
    event.preventDefault()

    event.returnValue =
      'You have unsaved changes, are you sure you want to leave?'
    return event.returnValue
  }
}

export default initWarnOnUnsavedChanges
