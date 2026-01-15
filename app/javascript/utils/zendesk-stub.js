window.zendeskPopupOpen = false

window.setZendeskStatus = function (status) {
  const statusChangeEvent = new CustomEvent('setZendeskStubStatus', { detail: status })
  document.body.dispatchEvent(statusChangeEvent)
}

window.zE = function (scope, command, callback = null) {
  if (scope === 'webWidget' && command === 'popout') {
    window.zendeskPopupOpen = true
  } else if (scope === 'webWidget:on' && command === 'chat:status') {
    document.body.addEventListener('setZendeskStubStatus', function (e) {
      callback(e.detail)
    })
  } else {
    throw Error('Unexpected Zendesk API function call')
  }
}
