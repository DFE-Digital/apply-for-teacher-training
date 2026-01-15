function UserSupportWebchat () {
  this.configureWidget()
  this.addButtonListener()
  this.unreadMessagerListener()
}

UserSupportWebchat.prototype.configureWidget = function () {
  const messagingButton = document.getElementById('messaging-button')

  messagingButton.style.display = 'initial'
  zE('messenger', 'hide')
  zE('messenger', 'close')

  if (navigator.cookieEnabled === false) {
    messagingButton.innerHTML += ' (cookies need to be enabled)'
    zE('messenger:set', 'cookies', false)
  }
}

UserSupportWebchat.prototype.unreadMessagerListener = function () {
  zE('messenger:on', 'unreadMessages', function (count) {
    if (count > 0) { // Ignore the generic message when the widget is created
      zE('messenger', 'show')
      zE('messenger', 'open')
    }
  })
}

UserSupportWebchat.prototype.addButtonListener = function () {
  const button = document.getElementById('messaging-button')

  button.addEventListener('click', function (e) {
    e.preventDefault()

    zE('messenger', 'show')
    zE('messenger', 'open')
  }, false)
}

const userSupportWebchat = () => new UserSupportWebchat()
export default userSupportWebchat
