import { getCookie, setCookie } from './cookies/cookie-helper'

export default class ClarityCookies {
  constructor (id, service) {
    this.id = id
    this.service = service
  }

  init () {
    const cookieConsent = getCookie(`consented-to-${this.service}-cookies`)

    if (cookieConsent === 'yes') {
      (function (c, l, a, r, i, t, y) {
        c[a] = c[a] || function () {
          (c[a].q = c[a].q || []).push(arguments)
        }
        t = l.createElement(r)
        t.async = 1
        t.src = 'https://www.clarity.ms/tag/' + i
        y = l.getElementsByTagName(r)[0]
        y.parentNode.insertBefore(t, y)
      })(window, document, 'clarity', 'script', this.id)

      window.clarity('consentv2', {
        ad_Storage: 'denied',
        analytics_Storage: 'granted'
      })
    } else {
      this.clearCookies()
    }
  }

  clearCookies = () => {
    if (window.clarity) {
      window.clarity('consentv2', {
        ad_Storage: 'denied',
        analytics_Storage: 'denied'
      })
    }

    ['_clck', '_clsk'].forEach((cookieName) => {
      const cookieValue = getCookie(cookieName)
      if (cookieValue) {
        setCookie(cookieName, '', {})
      }
    })
  }
}
