class NotificationService
  COMMAND = "command"
  PUSH = "push"

  attr_reader :user

  def initialize(user)
    @user = user
  end

  def deliver(type, data = {})
    method_name = "send_#{type}_notification"
    send(method_name, data)
  end

  private
    def send_command_notification(data)
      user_device = user.valid_user_device
      if user_device
        push_to_fcm(Array(user_device.push_notification_reg_id), data: { payload: data.to_json })
      end
    end

    def send_push_notification(data)
      data = data.with_indifferent_access
      user_device = user.valid_user_device
      if user_device
        push_to_fcm(Array(user_device.push_notification_reg_id), notification: { title: data[:title], body: data[:body]})
      end
    end

    def push_to_fcm(reg_ids, payload)
      response = fcm.send(reg_ids, payload)
      Rails.logger.info response.inspect
    end

    def fcm
      FCM.new(fcm_server_key)
    end

    def fcm_server_key
      if user.expert?
        Settings.fcm.expert_server_key
      else
        Settings.fcm.consumer_server_key
      end
    end
end
