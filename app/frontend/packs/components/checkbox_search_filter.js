import '../polyfills'

const outerHeight = (el) => {
  let height = el.offsetHeight
  const style = window.getComputedStyle(el, '')

  height += parseInt(style.marginTop) + parseInt(style.marginBottom)
  return height
}

class CheckboxSearchFilter {
  constructor (params) {
    this.params = params
    this.container = params.container
    this.container.classList.add('app-checkbox-filter--enhanced')
    this.checkboxes = this.container.querySelectorAll("input[type='checkbox']")
    this.checkboxesContainer = this.container.querySelector('.app-checkbox-filter__container')
    this.checkboxesInnerContainer = this.checkboxesContainer.querySelector('.app-checkbox-filter__container-inner')
    this.setup()
  }

  filterCheckboxes () {
    const textValue = this.sanitizeText(this.textBox.value)
    const allCheckboxes = this.getAllCheckboxes()

    for (let i = 0; i < allCheckboxes.length; i++) {
      const labelValue = this.sanitizeText(allCheckboxes[i].querySelector('.govuk-checkboxes__label').textContent)
      if (labelValue.search(textValue) === -1) {
        allCheckboxes[i].style.display = 'none'
      } else {
        allCheckboxes[i].style.display = 'block'
      }
    }

    this.updateStatusBox({
      foundCount: this.getAllVisibleCheckboxes().length,
      checkedCount: this.getAllVisibleCheckedCheckboxes().length
    })
  }

  getAllCheckboxes () {
    return this.checkboxesContainer.querySelectorAll('.govuk-checkboxes__item')
  }

  getAllVisibleCheckboxes () {
    return [].filter.call(this.getAllCheckboxes(), function (el) {
      return el.style.display === 'block'
    })
  }

  getAllVisibleCheckedCheckboxes () {
    return [].filter.call(this.getAllVisibleCheckboxes(), function (el) {
      return el.querySelector('.govuk-checkboxes__input').checked
    })
  }

  getTextBoxHtml () {
    const containerId = this.container.id
    const label = document.createElement('label')
    label.setAttribute('for', containerId + '-checkbox-filter__filter-input')
    label.className = 'govuk-label govuk-visually-hidden'
    label.innerHTML = this.params.textBox.label

    const input = document.createElement('input')
    input.className = 'app-checkbox-filter__filter-input govuk-input'
    input.setAttribute('id', containerId + '-checkbox-filter__filter-input')
    input.setAttribute('type', 'text')
    input.setAttribute('aria-describedby', containerId + '-checkboxes-status')
    input.setAttribute('aria-controls', containerId + '-checkboxes')
    input.setAttribute('autocomplete', 'off')
    input.setAttribute('spellcheck', 'false')

    return [label, input]
  }

  getVisibleCheckboxes () {
    const visibleCheckboxes = [].filter.call(this.checkboxes, (el) => this.isCheckboxInView(el))

    // add an extra checkbox, if the label of the first is too long it collapses onto itself
    visibleCheckboxes.push(this.checkboxes[visibleCheckboxes.length - 1])
    return visibleCheckboxes
  }

  isCheckboxInView (checkbox) {
    const initialOptionContainerHeight = this.checkboxesContainer.style.height
    const optionListOffsetTop = this.checkboxesInnerContainer.offsetTop
    const distanceFromTopOfContainer = checkbox.offsetTop - optionListOffsetTop
    return distanceFromTopOfContainer < initialOptionContainerHeight
  }

  onTextBoxKeyUp (e) {
    const ENTER_KEY = 13
    if (e.keyCode === ENTER_KEY) {
      e.preventDefault()
    } else {
      this.filterCheckboxes()
    }
  }

  sanitizeText (text) {
    text = text.replace(/&/g, 'and')
    text = text.replace(/[’',:–-]/g, '') // remove punctuation characters
    text = text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') // escape special characters
    return text.trim().replace(/\s\s+/g, ' ').toLowerCase() // replace multiple spaces with one
  }

  setContainerHeight (height) {
    this.checkboxesContainer.style.height = height
  }

  setup () {
    this.setupStatusBox()
    this.setupHeading()
    if (this.checkboxes.length >= 15) {
      this.setupTextBox()
    }
    this.setupHeight()
  }

  setupHeading () {
    const element = document.createElement('span')
    element.className = 'app-checkbox-filter__title'
    element.setAttribute('aria-hidden', 'true')

    this.heading = element
    this.container.prepend(this.heading)
  }

  setupHeight () {
    let initialOptionContainerHeight = this.checkboxesContainer.style.height
    let height = outerHeight(this.checkboxesInnerContainer)

    // check whether this is hidden by progressive disclosure,
    // because height calculations won't work
    if (this.checkboxesContainer.offsetParent === null) {
      initialOptionContainerHeight = 200
      height = 200
    }

    // Resize if the list is only slightly bigger than its container
    if (height < initialOptionContainerHeight + 50) {
      this.setContainerHeight(height + 1)
      return
    }

    // Resize to cut last item cleanly in half
    const visibleCheckboxes = this.getVisibleCheckboxes()
    const lastVisibleCheckbox = visibleCheckboxes[visibleCheckboxes.length - 1]
    const position = lastVisibleCheckbox.parentNode.offsetTop // parent element is relative
    this.setContainerHeight(position + (lastVisibleCheckbox.height / 1.5))
  }

  setupStatusBox () {
    const element = document.createElement('div')
    element.className = 'govuk-visually-hidden'
    element.id = this.container.id + '-checkboxes-status'
    element.setAttribute('role', 'status')

    this.statusBox = element
    this.updateStatusBox({
      foundCount: this.getAllVisibleCheckboxes().length,
      checkedCount: this.getAllVisibleCheckedCheckboxes().length
    })
    this.container.insertAdjacentElement('afterend', this.statusBox)
  }

  setupTextBox () {
    const tagContainer = this.container.querySelector('.app-checkbox-filter__selected')
    const textBoxElements = this.getTextBoxHtml()

    if (tagContainer) {
      for (let i = 0; i < textBoxElements.length; i++) {
        tagContainer.parentNode.insertBefore(textBoxElements[i], tagContainer.nextSibling)
      }
    } else {
      for (let i = 0; i < textBoxElements.length; i++) {
        this.heading.parentNode.insertBefore(textBoxElements[i], this.heading.nextSibling)
      }
    }

    this.textBox = this.container.querySelector('.app-checkbox-filter__filter-input')
    this.textBox.addEventListener('keyup', () => this.onTextBoxKeyUp(this))
  }

  updateStatusBox (params) {
    let status = '%found% options found, %selected% selected'
    status = status.replace(/%found%/, params.foundCount)
    status = status.replace(/%selected%/, params.checkedCount)
    this.statusBox.innerHTML = status
  }
}

const checkboxSearchFilter = (containerId, label) => {
  const containerElement = document.getElementById(containerId)

  if (containerElement) {
    return new CheckboxSearchFilter({
      container: containerElement,
      textBox: { label: label }
    })
  }
}

export default checkboxSearchFilter
