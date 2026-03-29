module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      increment_online_users
    end

    def disconnect
      decrement_online_users
    end

    private

    def find_verified_user
      env["warden"].user || "guest_#{SecureRandom.hex(4)}"
    end

    def increment_online_users
      REDIS.incr("online_users")
      broadcast_count
    end

    def decrement_online_users
      REDIS.decr("online_users")
      broadcast_count
    end

    def broadcast_count
      ActionCable.server.broadcast("online_users_channel", {
        count: REDIS.get("online_users").to_i
      })
    end
  end
end
