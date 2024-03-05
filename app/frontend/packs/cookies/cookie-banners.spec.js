import { checkConsentedToCookieExists } from './cookie-helper'
import cookieBanners from './cookie-banners'

jest.mock('./cookie-helper')

const templateHTML = `
<div class="govuk-cookie-banner" role="region" aria-label="Cookies on [Service name]" data-module="govuk-cookie-banner" data-qa="cookie-banner" data-service="service-name">
  <div class="govuk-cookie-banner__message govuk-width-container" hidden="hidden" data-module="govuk-cookie-banner-choice-message" data-qa="cookie-banner-choice-message">
    <div class="govuk-grid-row">
      <div class="govuk-grid-column-two-thirds">
        <h2 class="govuk-cookie-banner__heading">Cookies on [Service name]</h2>
        <div class="govuk-cookie-banner__content">
          <p>We use some essential cookies to make this service work.</p>
          <p>We’d also like to use analytics cookies so we can understand how you use the service and make improvements.</p>
        </div>
      </div>
    </div>

    <div class="govuk-button-group">
      <button name="button" type="submit" class="govuk-button" data-accept-cookie="true">Accept analytics cookies</button>
      <button name="button" type="submit" class="govuk-button" data-accept-cookie="false">Reject analytics cookies</button>
      <a data-qa="cookie-banner__preference-link" class="govuk-link" href="/cookies">View cookies</a>
    </div>
  </div>

  <div class="govuk-cookie-banner__message govuk-width-container" hidden="hidden" data-module="govuk-cookie-banner-confirmation-message" data-qa="cookie-banner-confirmation-message">
    <div class="govuk-grid-row">
      <div class="govuk-grid-column-two-thirds">
        <h2 class="govuk-cookie-banner__heading">Cookies on [Service name]</h2>
        <div class="govuk-cookie-banner__content">
          <p>
            You have
            <span id="user-answer"></span>
              analytics cookies. You can
            <a data-qa="cookie-banner__preference-link" class="govuk-link" href="/cookies">change your cookie settings</a>
              at any time.
          </p>
        </div>
      </div>
    </div>

    <div class="govuk-button-group">
      <button name="button" type="submit" class="govuk-button" data-accept-cookie="hide-banner">Hide cookie message</button>
    </div>
  </div>

  <div class="govuk-cookie-banner__message govuk-width-container" data-module="govuk-cookie-banner-fallback-message" data-qa="cookie-banner-fallback-message">
    <div class="govuk-grid-row">
      <div class="govuk-grid-column-two-thirds">
        <h2 class="govuk-cookie-banner__heading">Cookies on [Service name]</h2>
        <div class="govuk-cookie-banner__content">
          <p>We use cookies to make this service work and collect analytics information. To accept or reject cookies, turn on JavaScript in your browser settings or reload this page.</p>
        </div>
      </div>
    </div>
  </div>
</div>`

describe('Cookie banners', () => {
  describe('#constructor', () => {
    beforeEach(() => {
      document.body.innerHTML = templateHTML
    })

    afterEach(() => {
      jest.clearAllMocks()
    })

    it('doesn’t run if theres no cookie banner markup', () => {
      document.body.innerHTML = ''
      const banners = cookieBanners()

      expect(banners.$fallbackMessageModule).toBeNull()
    })

    it('does not display the fallback banner if javascript is enabled', () => {
      const banners = cookieBanners()

      expect(banners.$fallbackMessageModule.hidden).toBeTruthy()
    })

    it('displays the cookie banner only if user has not consented/rejected', () => {
      checkConsentedToCookieExists.mockImplementationOnce(() => false)
      const banners = cookieBanners()

      expect(banners.$choiceMessageModule.hidden).toBeFalsy()
    })

    it('hides the cookie banner if user has already consented/rejected', () => {
      checkConsentedToCookieExists.mockImplementationOnce(() => true)
      const banners = cookieBanners()

      expect(banners.$choiceMessageModule.hidden).toBeTruthy()
    })
  })

  describe('#acceptCookie', () => {
    it('hides the cookie choice message once a user has accepted cookies', () => {
      const banners = cookieBanners()
      banners.acceptCookie()

      expect(banners.$choiceMessageModule.hidden).toBeTruthy()
    })

    it('sets consented-to-cookies', () => {
      checkConsentedToCookieExists.mockImplementationOnce(() => null)
      const banners = cookieBanners()
      banners.acceptCookie()

      expect(checkConsentedToCookieExists).toBeTruthy()
    })
  })

  describe('#rejectCookie', () => {
    it('hides the cookie choice message once a user has rejected cookies', () => {
      const banners = cookieBanners()
      banners.rejectCookie()

      expect(banners.$choiceMessageModule.hidden).toBeTruthy()
    })

    it('sets consented-to-cookies', () => {
      checkConsentedToCookieExists.mockImplementationOnce(() => null)
      const banners = cookieBanners()
      banners.rejectCookie()

      expect(checkConsentedToCookieExists).toBeTruthy()
    })
  })

  describe('#showConfirmationMessage', () => {
    it('shows the confirmation message with "accepted" content', () => {
      const banners = cookieBanners()
      banners.showConfirmationMessage('accepted')

      expect(banners.$confirmationMessageModule.hidden).toBeFalsy()
      expect(banners.$confirmationMessageModule.querySelector('[id="user-answer"]').innerHTML).toEqual('accepted')
    })

    it('shows the confirmation message with "rejected" content', () => {
      const banners = cookieBanners()
      banners.showConfirmationMessage('rejected')

      expect(banners.$confirmationMessageModule.hidden).toBeFalsy()
      expect(banners.$confirmationMessageModule.querySelector('[id="user-answer"]').innerHTML).toEqual('rejected')
    })
  })
})
