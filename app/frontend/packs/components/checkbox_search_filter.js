class CheckboxSearchFilter {

  constructor(params) {
    this.params = params
    this.container = $(params.container)
    this.container.addClass('app-checkbox-filter--enhanced')
    this.checkboxes = this.container.find("input[type='checkbox']")
    this.checkboxesContainer = this.container.find('.app-checkbox-filter__container')
    this.checkboxesInnerContainer = this.checkboxesContainer.children('.app-checkbox-filter__container-inner')
    this.legend = this.container.find('legend')
    this.legend.addClass('govuk-visually-hidden')
    this.setup()
  }

  filterCheckboxes() {
    var textValue = this.sanitizeText(this.textBox.val())
    var allCheckboxes = this.getAllCheckboxes()

    allCheckboxes.hide()

    for(var i = 0; i < allCheckboxes.length; i++ ) {
      var labelValue = this.sanitizeText($(allCheckboxes[i]).find('.govuk-checkboxes__label').text())
      if(labelValue.search(textValue) !== -1) {
        $(allCheckboxes[i]).show()
      }
    }

    this.updateStatusBox({
      foundCount: this.getAllVisibleCheckboxes().length,
      checkedCount: this.getAllVisibleCheckedCheckboxes().length
    })
  }

  getAllCheckboxes() {
    return this.checkboxesContainer.find('.govuk-checkboxes__item')
  }

  getAllVisibleCheckboxes() {
    return this.getAllCheckboxes().filter(function(i, el) {
      return $(el).css('display') == 'block'
    })
  }

  getAllVisibleCheckedCheckboxes() {
    return this.getAllVisibleCheckboxes().filter(function(i, el) {
      return $(el).find('.govuk-checkboxes__input')[0].checked
    })
  }

  getTextBoxHtml() {
    var container_id = this.container[0].id
    var html = ''
    html += '<label for="' + container_id + '-checkbox-filter__filter-input" class="govuk-label govuk-visually-hidden">' + this.params.textBox.label + '</label>'
    html += '<input id="' + container_id + '-checkbox-filter__filter-input" class="app-checkbox-filter__filter-input govuk-input" type="text" aria-describedby="' + container_id + '-checkboxes-status" aria-controls="' + container_id + '-checkboxes" autocomplete="off" spellcheck="false">'
    return html
  }

  getVisibleCheckboxes() {
    var visibleCheckboxes = this.checkboxes.filter(this.isCheckboxInView.bind(this))
    // add an extra checkbox, if the label of the first is too long it collapses onto itself
    visibleCheckboxes = visibleCheckboxes.add(this.checkboxes[visibleCheckboxes.length])
    return visibleCheckboxes
  }

  isCheckboxInView(index, option) {
    var $checkbox = $(option)
    var initialOptionContainerHeight = this.checkboxesContainer.height()
    var optionListOffsetTop = this.checkboxesInnerContainer.offset().top
    var distanceFromTopOfContainer = $checkbox.offset().top - optionListOffsetTop
    return distanceFromTopOfContainer < initialOptionContainerHeight
  }

  onTextBoxKeyUp(e) {
    var ENTER_KEY = 13
    if (e.keyCode === ENTER_KEY) {
      e.preventDefault()
    } else {
      this.filterCheckboxes()
    }
  }

  sanitizeText(text) {
    text = text.replace(/&/g, 'and')
    text = text.replace(/[’',:–-]/g, '') // remove punctuation characters
    text = text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') // escape special characters
    return text.trim().replace(/\s\s+/g, ' ').toLowerCase() // replace multiple spaces with one
  }

  setContainerHeight(height) {
    this.checkboxesContainer.css({
      height: height
    })
  }

  setup() {
    this.setupStatusBox()
    this.setupHeading()
    this.setupTextBox()
    this.setupHeight()
  }

  setupHeading() {
    this.heading = $('<p class="app-checkbox-filter__title" aria-hidden="true">' + this.legend.text() + '</p>')
    this.container.prepend(this.heading)
  }

  setupHeight() {
    var initialOptionContainerHeight = this.checkboxesContainer.height()
    var height = this.checkboxesInnerContainer.outerHeight(true)

    // check whether this is hidden by progressive disclosure,
    // because height calculations won't work
    if (this.checkboxesContainer[0].offsetParent === null) {
      initialOptionContainerHeight = 200
      height = 200
    }

    // Resize if the list is only slightly bigger than its container
    if (height < initialOptionContainerHeight + 50) {
      this.setContainerHeight(height + 1)
      return
    }

    // Resize to cut last item cleanly in half
    var lastVisibleCheckbox = this.getVisibleCheckboxes().last()
    var position = lastVisibleCheckbox.parent()[0].offsetTop // parent element is relative
    this.setContainerHeight(position + (lastVisibleCheckbox.height() / 1.5))
  }

  setupStatusBox() {
    this.statusBox = $('<div class="govuk-visually-hidden" role="status" id="' + this.container[0].id + '-checkboxes-status"></div>')
    this.updateStatusBox({
      foundCount: this.getAllVisibleCheckboxes().length,
      checkedCount: this.getAllVisibleCheckedCheckboxes().length
    })
    this.container.append(this.statusBox)
  }

  setupTextBox() {
    var tagContainer = this.container.find('.app-checkbox-filter__selected')

    if(tagContainer[0]) {
      tagContainer.after(this.getTextBoxHtml())
    } else {
      this.heading.after(this.getTextBoxHtml())
    }
    this.textBox = this.container.find('.app-checkbox-filter__filter-input')
    this.textBox.on('keyup', $.proxy(this, 'onTextBoxKeyUp'))
  }

  updateStatusBox(params) {
    var status = '%found% options found, %selected% selected'
    status = status.replace(/%found%/, params.foundCount)
    status = status.replace(/%selected%/, params.checkedCount)
    this.statusBox.html(status)
  }
}

const checkbox_search_filter = (containerId, label) => {
  const $containerEl = $(containerId)

  if ($containerEl.length) {
    new CheckboxSearchFilter({
      container: $(containerId),
      textBox: { label: label }
    })
  }
}

export default checkbox_search_filter
