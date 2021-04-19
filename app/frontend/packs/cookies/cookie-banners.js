import { setConsentedToCookie, checkConsentedToCookieExists } from './cookie-helper'

class CookieBanners {
  constructor () {
    this.$fallbackBanner = document.querySelector('[data-module="govuk-fallback-cookie-banner"]')

    // If the page doesn't have the fallback banner then stop
    if (!this.$fallbackBanner) {
      return
    }

    this.$fallbackBanner.hidden = true
    this.$cookieAcceptRejectBanner = document.querySelector('[data-module="govuk-cookie-banner"]')
    this.service = this.$cookieAcceptRejectBanner.dataset.service
    this.$cookieConfirmationBanner = document.querySelector('[data-module="govuk-cookie-confirmation-banner"]')
    this.acceptButton = this.$cookieAcceptRejectBanner.querySelector('[data-accept-cookie="true"]')
    this.rejectButton = this.$cookieAcceptRejectBanner.querySelector('[data-accept-cookie="false"]')
    this.hideMessageButton = this.$cookieConfirmationBanner.querySelector('button')

    // consentCookie is false if user has not accept/rejected cookies
    if (!checkConsentedToCookieExists(this.service)) {
      this.showCookieAcceptRejectBanner()
      this.bindEvents()
    }
  }

  bindEvents () {
    this.acceptButton.addEventListener('click', () => this.acceptCookie())
    this.acceptButton.addEventListener('click', () => this.showCookieConfirmationBanner('accepted'))
    this.rejectButton.addEventListener('click', () => this.rejectCookie())
    this.rejectButton.addEventListener('click', () => this.showCookieConfirmationBanner('rejected'))
    this.hideMessageButton.addEventListener('click', () => this.hideBanner(this.$cookieConfirmationBanner))
  }

  acceptCookie () {
    this.hideBanner(this.$cookieAcceptRejectBanner)
    setConsentedToCookie({ userAnswer: 'yes', service: this.service })
  }

  rejectCookie () {
    this.hideBanner(this.$cookieAcceptRejectBanner)
    setConsentedToCookie({ userAnswer: 'no', service: this.service })
  }

  showCookieConfirmationBanner (content) {
    this.$cookieConfirmationBanner.hidden = false
    this.$cookieConfirmationBanner.querySelector('[id="user-answer"]').textContent = `${content}`
  }

  showCookieAcceptRejectBanner () {
    this.$cookieAcceptRejectBanner.hidden = false
  }

  hideBanner (module) {
    module.hidden = true
  }
}

const cookieBanners = () => new CookieBanners()

export default cookieBanners
