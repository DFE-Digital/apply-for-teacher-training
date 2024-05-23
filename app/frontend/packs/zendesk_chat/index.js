function ZendeskChat() {
  zE('messenger', 'open');

  observer.observe(targetNode, config);
}

// Select the node that will be observed for mutations
const targetNode = document.querySelector('body');
//const targetNode = document.getElementById('zendesk')

// Options for the observer (which mutations to observe)
const config = { attributes: true, childList: true, subtree: true };

// Callback function to execute when mutations are observed
const callback = (mutationList, observer) => {
  for (const mutation of mutationList) {
    //console.log("mutation")
    //console.log(mutation)
    if (mutation.target.tagName === "IFRAME" && mutation.type === "attributes"){
      mutation.target.style.width = "100%"
      mutation.target.style.height = "100%"
      mutation.target.style.maxHeight = "unset"
      mutation.target.style.position = "relative"
      mutation.target.style.inset = "unset"
    } else if (mutation.target.tagName === "BODY" && mutation.type === "attributes") {
      document.querySelectorAll("iframe")[1].contentWindow.document.querySelector(".fbohUV").parentElement.style.display = "none"
      //iFrame.contentWindow.document.querySelector(".fbohUV").parentElement.style.display = "none"
//      mutation.target.style.margin = "0"
    }
  }
};

// Create an observer instance linked to the callback function
const observer = new MutationObserver(callback);

// Start observing the target node for configured mutations
observer.observe(targetNode, config);

// Later, you can stop observing
observer.disconnect();


const zendeskChat = () => new ZendeskChat()
export default zendeskChat
