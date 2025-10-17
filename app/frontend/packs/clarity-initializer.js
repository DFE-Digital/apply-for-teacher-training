import ClarityCookies from './clarity-cookies'

const initClarityCookies = (serviceName) => {
  const clarityId = document.querySelector('[data-clarity-id]').dataset.clarityId

  if (clarityId && serviceName) {
    const clarity = new ClarityCookies(clarityId, serviceName)
    clarity.init()
  }
}

export default initClarityCookies
