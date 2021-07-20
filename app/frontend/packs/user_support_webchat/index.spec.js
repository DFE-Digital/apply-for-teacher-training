import userSupportWebchat from './index.js'
require('./../zendesk-stub.js')

describe('userSupportWebchat', () => {
  beforeEach(() => {
    document.body.innerHTML = `
        <div id="test-container">
          <div id="app-web-chat">
            <span class="app-web-chat__unavailable"></span>
          </div>
          <div id="launcher"></div>
        </div>
      `
    userSupportWebchat()
  })

  it('should instantiate a user support webchat', () => {
    expect(document.querySelector('#test-container')).toMatchSnapshot()
  })

  describe('hideLauncher', () => {
    it('should hide the default launcher element', () => {
      expect(document.querySelector('#launcher').classList).not.toContain('moj-hidden')
      window.setZendeskStatus('online')
      expect(document.querySelector('#launcher').classList).toContain('moj-hidden')
    })
  })
})
