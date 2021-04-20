const CANDIDATE_GA_TAG = '_gat_gtag_UA_112932657_3'
const MANAGE_GA_TAG = '_gat_gtag_UA_112932657_8'
const ANALYTICAL_COOKIES = [
  '_ga', CANDIDATE_GA_TAG, MANAGE_GA_TAG, '_gid'
]

/** @description sets the cookie with the users consent and returns its value
 * @returns {Boolean} true, if it successfully sets the consented-to-cookies
 */
const setConsentedToCookie = ({ userAnswer, service }) => {
  setCookie(`consented-to-${service}-cookies`, userAnswer, { days: 182 })
  removeOptionalCookies(userAnswer)
}

/** @summary Checks if consented-to-cookies cookie exists
 * @returns {Boolean} true if it find the consented-to-cookies & false if it does not find it
*/
const checkConsentedToCookieExists = (service) => {
  return getCookie(`consented-to-${service}-cookies`) != null
}

/**
 *  @private
 *  @summary Removes optional cookies such as GA related cookies
 *  @param {Boolean} userDecision - false if they rejected cookies or true
 *  if they consented
 *  @description If a user has decided to reject cookies then we have
 *  to expire any optional cookie that has been set. In our case its
 *  will be cookies created by Google Analytics.
 */
const removeOptionalCookies = (userDecision) => {
  if (userDecision === false) {
    ANALYTICAL_COOKIES.forEach(cookieName => {
      const doesCookieExist = getCookie(cookieName) != null

      if (doesCookieExist) {
        setCookie(cookieName, '', { days: -1 })
      }
    })
  }
}

/**
 *  @private
 *  @summary Fetches and returns a cookie by cookie name
 *  @param {string} name - Cookie name which the method should lookup
 *  @returns {string} Cookie string in key=value format
 *  @returns {null} if Cookie is not found
 *  @description If a user has decided to reject cookies then we have
 *  to expire any optional cookie that has been set. In our case its
 *  will be cookies created by Google Analytics.
 */
function getCookie (name) {
  const nameEQ = name + '='
  const cookies = document.cookie.split(';')
  for (let i = 0, len = cookies.length; i < len; i++) {
    let cookie = cookies[i]
    while (cookie.charAt(0) === ' ') {
      cookie = cookie.substring(1, cookie.length)
    }
    if (cookie.indexOf(nameEQ) === 0) {
      return decodeURIComponent(cookie.substring(nameEQ.length))
    }
  }
  return null
}

/**
 *  @private
 *  @summary Sets a cookie
 *  @param {string} name - Cookie name
 *  @param {string} value - Value the cookie will be set to
 *  @param {object} options - used to set cookie options like secure/ expiry date etc
 *  @example chocolateChip cookie value is tasty and expires in 2 days time
 *  setCookie('chocolateChip', 'Tasty', {days: 2 })
 *  @example Delete/Expire existing chocolateChip cookie
 *  setCookie('chocolateChip', '', {days: -1 })
 */
function setCookie (name, value, options) {
  if (typeof options === 'undefined') {
    options = {}
  }
  let cookieString = name + '=' + value + '; path=/'
  if (options.days) {
    const date = new Date()
    date.setTime(date.getTime() + (options.days * 24 * 60 * 60 * 1000))
    cookieString = cookieString + '; expires=' + date.toGMTString()
  }
  if (document.location.protocol === 'https:') {
    cookieString = cookieString + '; Secure'
  }
  document.cookie = cookieString
}

export {
  setConsentedToCookie,
  checkConsentedToCookieExists
}
