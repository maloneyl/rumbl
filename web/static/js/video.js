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

    msgContainer.addEventListener("click", e => {
      e.preventDefault()
      let seconds = e.target.getAttribute("data-seek") || e.target.parentNode.getAttribute("data-seek")
      if(!seconds){ return }
      Player.seekTo(seconds)
    })

    vidChannel.join()
      .receive("ok", resp => {
        this.scheduleMessages(msgContainer, resp.annotations)
        // instead of rendering all annotations immediately, we schedule them
        // to render based on the current player time
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
  },

  scheduleMessages(msgContainer, annotations){
    // starts an interval timer that fires every second
    setTimeout(() => {
      let currentTime = Player.getCurrentTime()
      let remaining = this.renderAtTime(annotations, currentTime, msgContainer)
      this.scheduleMessages(msgContainer, remaining)
    }, 1000)
  },

  renderAtTime(annotations, seconds, msgContainer){
    return annotations.filter( annotation => {
      if(annotation.at > seconds){ // i.e. if annotation occurs after current player time
        return true // keep a tab on the remaining annotations to filter on the next call
      } else {
        this.renderAnnotation(msgContainer, annotation)
        return false // exclude it from the remaining set
      }
    })
  },

  formatTime(at){
    let date = new Date(null)
    date.setSeconds(at / 1000)
    return date.toISOString().substr(14, 5)
  }
}

export default Video
