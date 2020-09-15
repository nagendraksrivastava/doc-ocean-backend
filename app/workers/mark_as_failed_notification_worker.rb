class MarkAsFailedNotificationWorker
  include Sidekiq::Worker

  def perform(notification_id)
    ActiveRecord::Base.transaction do
      notification = Notification.lock.find(notification_id)
      notification.fail!
    end
  end
end
