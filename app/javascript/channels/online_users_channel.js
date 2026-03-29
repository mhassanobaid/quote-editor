import consumer from "./consumer"

consumer.subscriptions.create("OnlineUsersChannel", {
  received(data) {
    const el = document.getElementById("users-count")
    if (el) {
      el.innerText = data.count
    }
  }
})
