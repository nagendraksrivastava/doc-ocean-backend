class CommandNotification < Notification
  EXPERT_NEW_APPOINTMENT = "EXPERT:NEW_APPOINTMENT"

  aasm column: :status, whiny_transitions: false do
    state :created, initial: true
    state :received
    state :failed
    state :accepted
    state :rejected

    event :receive do
      transitions from: :created, to: :received
    end

    event :fail, after: :on_failed do
      transitions from: [:created, :received], to: :failed
    end

    event :accept, after: :on_accepted do
      transitions from: [:created, :received], to: :accepted, guard: :can_accept?
    end

    event :reject, after: :on_rejected do
      transitions from: [:created, :received], to: :rejected
    end
  end

  def can_accept?
    !other_broadcast_notifications.any?(&:accepted?)
  end

  def on_accepted
    other_broadcast_notifications.each do |notification|
      if notification.created?
        notification.fail!
      elsif notification.received?
        notification.reject!
      end
    end
    self.notifiable.on_notification_accept(self) if self.notifiable.respond_to?(:on_notification_accept)
  end

  def on_rejected
    check_and_handle_all_failure
  end

  def on_failed
    check_and_handle_all_failure
  end

  def check_and_handle_all_failure
    if other_broadcast_notifications.all?{|n| n.rejected? || n.failed?}
      self.notifiable.on_all_notfications_failed(self) if self.notifiable.respond_to?(:on_all_notfications_failed)
    end
  end

  def send_notification
    data = {
      notification_id: self.id,
      type: self.code,
      appointment_number: self.notifiable.number,
      service_type: self.notifiable.service_type
    }
    data[:notification_content] = self.data[:notification_content] if self.data && self.data[:notification_content].present?
    NotificationWorker.perform_async(self.user_id, NotificationService::COMMAND, data)

    MarkAsFailedNotificationWorker.perform_in(1.minute, self.id)
  end

  private
    def other_broadcast_notifications
      @notifications ||= CommandNotification.where.not(id: self.id).
        where(notifiable_type: self.notifiable_type, notifiable_id: self.notifiable_id)
    end
end
