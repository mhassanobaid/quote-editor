import consumer from "./consumer"

let subscription

function subscribe() {
  if (subscription) {
    subscription.unsubscribe()
  }

  subscription = consumer.subscriptions.create("OnlineUsersChannel", {
    received(data) {
      const el = document.getElementById("users-count")
      if (el) {
        el.innerText = data.count
      }
    }
  })
}

document.addEventListener("turbo:load", () => {
  subscribe()
})
