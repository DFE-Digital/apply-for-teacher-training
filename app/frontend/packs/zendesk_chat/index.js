function ZendeskChat() {
  zE('messenger', 'open');

  //this.addButtonListener()

  //zE("messenger:on", "open", function () {
  //  console.log(`You have opened the messaging Web Widget`)
  //})
}

ZendeskChat.prototype.addButtonListener = function () {
  this.button = document.getElementById('zendesk-link')
  this.button.addEventListener('click', function (e) {
    e.preventDefault()
    console.log("button click")

  //  zE('messenger', 'show');
    //zE('messenger', 'show');

  }, false)
}

const zendeskChat = () => new ZendeskChat()
export default zendeskChat
