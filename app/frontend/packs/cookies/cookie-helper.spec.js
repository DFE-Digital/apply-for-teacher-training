import {
  setConsentedToCookie,
  checkConsentedToCookieExists
} from './cookie-helper'

const setCookie = (cookieName, value) => {
  document.cookie = `${cookieName}=${value};`
}

const clearCookie = (cookieName) => {
  document.cookie = `${cookieName}=; expires=Thu, 01 Jan 1970 00:00:00 GMT`
}

const fetchAllCookies = () => {
  const allCookies = []

  if (document.cookie) {
    document.cookie.split(/;/).forEach(cookie => {
      allCookies.push(cookie.trim())
    })
  }
  return allCookies
}

describe('cookie helper methods', () => {
  beforeEach(() => {
    clearCookie('consented-to-candidate-cookies')
  })

  describe('setConsentedToCookie', () => {
    it('uses a string value to set a cookie', () => {
      setConsentedToCookie({ userAnswer: 'yes', service: 'candidate' })

      expect(document.cookie).toEqual('consented-to-candidate-cookies=yes')
    })

    it('uses a string value to set a cookie - User rejects cookies', () => {
      setConsentedToCookie({ userAnswer: 'no', service: 'candidate' })

      expect(document.cookie).toEqual('consented-to-candidate-cookies=no')
    })

    it('removes optional cookies if a user rejected cookie', () => {
      const fakeEssentialCookies = ['taste', 'smell', 'sight']
      const fakeOptionalCookies = ['_ga', '_gat']

      fakeEssentialCookies.forEach(cookieName => {
        setCookie(cookieName, 1)
      })
      fakeOptionalCookies.forEach(cookieName => {
        setCookie(cookieName, 1)
      })

      expect(fetchAllCookies().length).toEqual(5)

      setConsentedToCookie({ userAnswer: 'no', service: 'candidate' })

      expect(fetchAllCookies().length).toEqual((6))
    })
  })

  describe('checkConsentedToCookieExists', () => {
    it('returns true if cookie exists - User rejected', () => {
      setCookie('consented-to-candidate-cookies', 'yes')
      const response = checkConsentedToCookieExists('candidate')

      expect(response).toEqual(true)
    })

    it('returns true if cookie exists - User consented', () => {
      setCookie('consented-to-candidate-cookies', 'yes')
      const response = checkConsentedToCookieExists('candidate')

      expect(response).toEqual(true)
    })

    it('returns false if cookie does not exist', () => {
      setCookie('some-other-cookie', 'not-consented')
      const response = checkConsentedToCookieExists('candidate')

      expect(response).toEqual(false)

      clearCookie('some-other-cookie')
    })
  })
})
