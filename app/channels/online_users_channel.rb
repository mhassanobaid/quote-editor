class OnlineUsersChannel < ApplicationCable::Channel
  def subscribed
    stream_from "online_users_channel"

    transmit({
      count: REDIS.get("online_users").to_i
    })
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
