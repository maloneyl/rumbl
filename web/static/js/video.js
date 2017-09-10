import Player from "./player"

let Video = {
  init(socket, element){ if(!element){ return }
    let playerId = element.getAttribute("data-player-id")
    let videoId = element.getAttribute("data-id")
    socket.connect()
    Player.init(element.id, playerId, () => {
      this.onReady(videoId, socket)
    })
  },

  onReady(videoId, socket){
    let msgContainer = document.getElementById("msg-container")
    let msgInput = document.getElementById("msg-input")
    let postButton = document.getElementById("msg-submit")
    let vidChannel = socket.channel("videos:" + videoId) // identifier for our topic

    postButton.addEventListener("click", e => {
      let payload = {body: msgInput.value, at: Player.getCurrentTime()}

      // request-response-style messaging over a socket connection
      vidChannel.push("new_annotation", payload)
                .receive("error", e => console.log(e)) // not a true synchronous operation

      msgInput.value = ""
    })

    vidChannel.on("new_annotation", (resp) => {
      this.renderAnnotation(msgContainer, resp)
    })

    vidChannel.join()
      .receive("ok", ({annotations}) => {
        annotations.forEach( annotation => this.renderAnnotation(msgContainer, annotation) )
      })
      .receive("error", reason => console.log("join failed", reason))
  },

  // escape user input before injecting values into the page
  esc(str){
    let div = document.createElement("div")
    div.appendChild(document.createTextNode(str))
    return div.innerHTML
  },

  renderAnnotation(msgContainer, {user, body, at}){
    let template = document.createElement("div")
    template.innerHTML = `
    <a href="#" data-seek="${this.esc(at)}">
      <b>${this.esc(user.username)}</b>: ${this.esc(body)}
    </a>
    `
    msgContainer.appendChild(template)
    msgContainer.scrollTop = msgContainer.scrollHeight
  }
}

export default Video
