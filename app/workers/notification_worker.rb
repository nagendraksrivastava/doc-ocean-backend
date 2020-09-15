class NotificationWorker
  include Sidekiq::Worker

  def perform(user_id, notification_type, data)
    user = User.find(user_id)
    NotificationService.new(user).deliver(notification_type, data)
  end
end
