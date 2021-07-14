function UserSupportWebchat () {
  this.container = document.getElementById('app-web-chat')

  this.configureWidget()
  this.setupElements()
  this.addButtonListener()
  this.addStatusChangeListener()
}

UserSupportWebchat.prototype.configureWidget = function () {
  window.zESettings = {
    webWidget: {
      chat: {
        suppress: true
      }
    }
  }
}

UserSupportWebchat.prototype.setupElements = function () {
  this.enabledContainer = document.createElement('span')
  this.enabledContainer.className = 'moj-hidden'

  this.defaultContainer = document.querySelector('.app-web-chat__unavailable')

  this.button = document.createElement('a')
  this.button.href = '#'
  this.button.className = 'govuk-link govuk-footer__link app-web-chat__button'
  this.button.innerHTML = 'Speak to an adviser now (opens in new window)'
  this.enabledContainer.append(this.button)

  this.disabledContainer = document.createElement('span')
  this.disabledContainer.className = 'app-web-chat__offline moj-hidden'
  this.disabledContainer.innerHTML = 'Available Monday to Friday, 10am to midday (except public holidays).'

  this.container.append(this.enabledContainer)
  this.container.append(this.disabledContainer)
}

UserSupportWebchat.prototype.addButtonListener = function () {
  this.button.addEventListener('click', function (e) {
    e.preventDefault()

    zE('webWidget', 'popout')
  }, false)
}

UserSupportWebchat.prototype.addStatusChangeListener = function () {
  zE('webWidget:on', 'chat:status', function (status) {
    this.defaultContainer.classList.add('moj-hidden')

    if (status === 'online') {
      this.enableChat()
    } else {
      this.disableChat()
    }
  }.bind(this))
}

UserSupportWebchat.prototype.enableChat = function () {
  this.disabledContainer.classList.add('moj-hidden')
  this.enabledContainer.classList.remove('moj-hidden')
}

UserSupportWebchat.prototype.disableChat = function () {
  this.disabledContainer.classList.remove('moj-hidden')
  this.enabledContainer.classList.add('moj-hidden')
}

const userSupportWebchat = () => new UserSupportWebchat()
export default userSupportWebchat
