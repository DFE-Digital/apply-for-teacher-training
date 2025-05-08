function ShowMoreShowLess () {
  this.showMoreLinks = document.getElementsByClassName('app-show-more-show-less')

  const context = this

  if (context.showMoreLinks.length) {
    [].forEach.call(context.showMoreLinks, function (showMoreLink) {
      context.setShowMoreLinkListener(showMoreLink)
    })
  }
}

ShowMoreShowLess.prototype.setShowMoreLinkListener = function (showMoreLink) {
  showMoreLink.addEventListener('click', this.expandContractTarget)
  showMoreLink.classList.remove('govuk-visually-hidden')
}

ShowMoreShowLess.prototype.expandContractTarget = function (event) {
  event.preventDefault()

  const link = event.target
  const container = document.getElementById(link.getAttribute('data-container'))
  const sectionContainer = document.getElementById(link.getAttribute('data-section-container'))
  const lessText = link.getAttribute('data-show-less')
  const moreText = link.getAttribute('data-show-more')
  const isExpanded = link.getAttribute('aria-expanded')

  if (isExpanded === 'true') {
    container.classList.add('govuk-visually-hidden')
    link.text = moreText
    link.setAttribute('aria-expanded', false)
    if (sectionContainer !== null) {
      sectionContainer.scrollIntoView({ block: 'start' })
    }
  } else {
    container.classList.remove('govuk-visually-hidden')
    link.text = lessText
    link.setAttribute('aria-expanded', true)
    if (sectionContainer === null) {
      container.scrollIntoView({ block: 'start' })
    } else {
      sectionContainer.scrollIntoView({ block: 'start' })
    }
  }
}

const showMoreShowLess = () => new ShowMoreShowLess()
export default showMoreShowLess
