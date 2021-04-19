import { checkConsentedToCookieExists } from './cookie-helper'
import cookieBanners from './cookie-banners'

jest.mock('./cookie-helper')

const templateHTML = `
<div class="govuk-cookie-banner" role="region" aria-label="Cookie banner" data-module="govuk-cookie-banner" data-service="candidate" hidden>
  <div class="govuk-cookie-banner__message govuk-width-container">
    <div class="govuk-grid-row">
      <div class="govuk-grid-column-two-thirds">
        <h2 class="govuk-cookie-banner__heading govuk-heading-m">
          Cookies on Apply for teacher training
        </h2>
        <div class="govuk-cookie-banner__content">
          <p class="govuk-body">We use some essential cookies to make this service work.</p>
          <p class="govuk-body">We’d also like to use analytics cookies so we can understand how you use the service and make improvements.</p>
        </div>
      </div>
    </div>

    <div class="govuk-button-group">
      <button type="button" class="govuk-button" data-accept-cookie="true">Accept analytics cookies</button>
      <button type="button" class="govuk-button" data-accept-cookie="false">Reject analytics cookies</button>
      <a class="govuk-link" href="/cookies">View cookies</a>
    </div>
  </div>
</div>

<div class="govuk-cookie-banner" role="region" aria-label="Cookie banner" data-module="govuk-cookie-confirmation-banner" hidden>
  <div class="govuk-cookie-banner__message govuk-width-container">
    <div class="govuk-grid-row">
      <div class="govuk-grid-column-two-thirds">
        <div class="govuk-cookie-banner__content">
          <p>You’ve <span id="user-answer"></span> analytics cookies. You can <a data-qa="cookie-banner__preference-link" class="govuk-link" href="/cookies">change your cookie settings</a> at any time.</p>
        </div>
      </div>
    </div>

    <div class="govuk-button-group">
      <button type="button" class="govuk-button" data-accept-cookie="hide-banner">Hide this message</button>
    </div>
  </div>
</div>

<div class="govuk-cookie-banner" role="region" aria-label="Cookie banner" data-module="govuk-fallback-cookie-banner" hidden>
  <div class="govuk-cookie-banner__message govuk-width-container">
    <div class="govuk-grid-row">
      <div class="govuk-grid-column-two-thirds">
        <h2 class="govuk-cookie-banner__heading govuk-heading-m">
          Cookies on Apply for teacher training
        </h2>

        <div class="govuk-cookie-banner__content">
          <p class="govuk-body">We use cookies to make this service work and collect analytics information. To accept or reject cookies, turn on JavaScript in your browser settings or reload this page.</p>
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

    it('does not display the fallback banner if javascript is enabled', () => {
      const banners = cookieBanners()

      expect(banners.$fallbackBanner.hidden).toBeTruthy()
    })

    it('displays the Cookie Accept/Reject Banner only if user has not consented/rejected', () => {
      checkConsentedToCookieExists.mockImplementationOnce(() => false)

      const banners = cookieBanners()

      expect(banners.$cookieAcceptRejectBanner.hidden).toBeFalsy()
    })

    it('hides the Cookie Accept/Reject Banner if user has consented/rejected', () => {
      checkConsentedToCookieExists.mockImplementationOnce(() => true)

      const banners = cookieBanners()

      expect(banners.$cookieAcceptRejectBanner.hidden).toBeTruthy()
    })
  })

  describe('#acceptCookie', () => {
    it('hides the cookie banner once a user has accepted cookies', () => {
      const banners = cookieBanners()

      banners.acceptCookie()

      expect(banners.$cookieAcceptRejectBanner.hidden).toBeTruthy()
    })

    it('sets consented-to-cookies', () => {
      checkConsentedToCookieExists.mockImplementationOnce(() => null)

      const banners = cookieBanners()

      banners.acceptCookie()
      expect(checkConsentedToCookieExists).toBeTruthy()
    })
  })

  describe('#rejectCookie', () => {
    it('hides the cookie Accept / Reject banner once a user has rejected cookies', () => {
      const banners = cookieBanners()

      banners.rejectCookie()

      expect(banners.$cookieAcceptRejectBanner.hidden).toBeTruthy()
    })

    it('sets consented-to-cookies', () => {
      checkConsentedToCookieExists.mockImplementationOnce(() => null)

      const banners = cookieBanners()

      banners.rejectCookie()
      expect(checkConsentedToCookieExists).toBeTruthy()
    })
  })

  describe('#showCookieConfirmationBanner', () => {
    it('shows the cookie confirmation banner with "accepted" content', () => {
      const banners = cookieBanners()

      banners.showCookieConfirmationBanner('accepted')

      expect(banners.$cookieConfirmationBanner.hidden).toBeFalsy()
      expect(banners.$cookieConfirmationBanner.querySelector('[id="user-answer"]').innerHTML).toEqual('accepted')
    })

    it('shows the cookie confirmation banner with "rejected" content', () => {
      const banners = cookieBanners()

      banners.showCookieConfirmationBanner('rejected')

      expect(banners.$cookieConfirmationBanner.hidden).toBeFalsy()
      expect(banners.$cookieConfirmationBanner.querySelector('[id="user-answer"]').innerHTML).toEqual('rejected')
    })
  })
})
