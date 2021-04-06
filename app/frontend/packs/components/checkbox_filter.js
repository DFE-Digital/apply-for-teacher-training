let CheckboxFilter = function(params) {
  this.params = params
  this.container = $(params.container)
  this.container.addClass('app-checkbox-filter--enhanced')
  this.checkboxes = this.container.find("input[type='checkbox']")
  this.checkboxesContainer = this.container.find('.app-checkbox-filter__container')
  this.checkboxesInnerContainer = this.checkboxesContainer.children('.app-checkbox-filter__container-inner')
  this.legend = this.container.find('legend')
  this.legend.addClass('govuk-visually-hidden')
  this.setupStatusBox()
  this.setupHeading()
  this.setupTextBox()
  this.setupHeight()
}

CheckboxFilter.prototype.setupHeading = function() {
  this.heading = $('<p class="app-checkbox-filter__title" aria-hidden="true">' + this.legend.text() + '</p>')
  this.container.prepend(this.heading)
}

CheckboxFilter.prototype.setupTextBox = function() {
  var tagContainer = this.container.find('.app-checkbox-filter__selected')
  if(tagContainer[0]) {
    tagContainer.after(this.getTextBoxHtml())
  } else {
    this.heading.after(this.getTextBoxHtml())
  }

  this.textBox = this.container.find('.app-checkbox-filter__filter-input')
  this.textBox.on('keyup', $.proxy(this, 'onTextBoxKeyUp'))
}

CheckboxFilter.prototype.getTextBoxHtml = function() {
  var id = this.container[0].id
  var html = ''
  html += '<label for="' + id + '-checkbox-filter__filter-input" class="govuk-label govuk-visually-hidden">' + this.params.textBox.label + '</label>'
  html += '<input id="' + id + '-checkbox-filter__filter-input" class="app-checkbox-filter__filter-input govuk-input" type="text" aria-describedby="' + id + '-checkboxes-status" aria-controls="' + id + '-checkboxes" autocomplete="off" spellcheck="false">'
  return html
}

CheckboxFilter.prototype.setupStatusBox = function() {
  this.statusBox = $('<div class="govuk-visually-hidden" role="status" id="' + this.container[0].id + '-checkboxes-status"></div>')
  this.updateStatusBox({
    foundCount: this.getAllVisibleCheckboxes().length,
    checkedCount: this.getAllVisibleCheckedCheckboxes().length
  })
  this.container.append(this.statusBox)
}

CheckboxFilter.prototype.updateStatusBox = function(params) {
  var status = '%found% options found, %selected% selected'
  status = status.replace(/%found%/, params.foundCount)
  status = status.replace(/%selected%/, params.checkedCount)
  this.statusBox.html(status)
}

CheckboxFilter.prototype.onTextBoxKeyUp = function(e) {
  var ENTER_KEY = 13
  if (e.keyCode === ENTER_KEY) {
    e.preventDefault()
  } else {
    this.filterCheckboxes()
  }
}

CheckboxFilter.prototype.cleanString = function(text) {
  text = text.replace(/&/g, 'and')
  text = text.replace(/[’',:–-]/g, '') // remove punctuation characters
  text = text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') // escape special characters
  return text.trim().replace(/\s\s+/g, ' ').toLowerCase() // replace multiple spaces with one
}

CheckboxFilter.prototype.filterCheckboxes = function() {
  var textValue = this.cleanString(this.textBox.val())

  var allCheckboxes = this.getAllCheckboxes()
  // hide all checkboxes
  allCheckboxes.hide()

  for(var i = 0; i < allCheckboxes.length; i++ ) {
    var labelValue = this.cleanString($(allCheckboxes[i]).find('.govuk-checkboxes__label').text())
    if(labelValue.search(textValue) !== -1) {
      $(allCheckboxes[i]).show()
    }
  }

  this.updateStatusBox({
    foundCount: this.getAllVisibleCheckboxes().length,
    checkedCount: this.getAllVisibleCheckedCheckboxes().length
  })
}

CheckboxFilter.prototype.getAllCheckboxes = function() {
  return this.checkboxesContainer.find('.govuk-checkboxes__item')
}

CheckboxFilter.prototype.getAllVisibleCheckboxes = function() {
  return this.getAllCheckboxes().filter(function(i, el) {
    return $(el).css('display') == 'block'
  })
}

CheckboxFilter.prototype.getAllVisibleCheckedCheckboxes = function() {
  return this.getAllVisibleCheckboxes().filter(function(i, el) {
    return $(el).find('.govuk-checkboxes__input')[0].checked
  })
}

CheckboxFilter.prototype.setContainerHeight = function(height) {
  this.checkboxesContainer.css({
    height: height
  })
}

CheckboxFilter.prototype.isCheckboxInView = function(index, option) {
  var $checkbox = $(option)
  var initialOptionContainerHeight = this.checkboxesContainer.height()
  var optionListOffsetTop = this.checkboxesInnerContainer.offset().top
  var distanceFromTopOfContainer = $checkbox.offset().top - optionListOffsetTop
  return distanceFromTopOfContainer < initialOptionContainerHeight
}

CheckboxFilter.prototype.getVisibleCheckboxes = function() {
  var visibleCheckboxes = this.checkboxes.filter(this.isCheckboxInView.bind(this))
  // add an extra checkbox, if the label of the first is too long it collapses onto itself
  visibleCheckboxes = visibleCheckboxes.add(this.checkboxes[visibleCheckboxes.length])
  return visibleCheckboxes
}

CheckboxFilter.prototype.setupHeight = function() {
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

const checkbox_filter = (containerId, label) => {
  const $containerEl = $(containerId)

  if ($containerEl.length) {
    new CheckboxFilter({
      container: $(containerId),
      textBox: { label: label }
    })
  }
}

export default checkbox_filter
