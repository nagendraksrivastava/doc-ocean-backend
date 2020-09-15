class Notification < ActiveRecord::Base
  include AASM

  serialize :data
  belongs_to :notifiable, polymorphic: true
  belongs_to :user
  after_commit :send_notification

  aasm column: :status, whiny_transitions: false do
    state :created, initial: true
    state :received
    state :failed
    state :accepted
    state :rejected

    event :receive do
      transitions from: :created, to: :received
    end

    event :fail do
      transitions from: :created, to: :failed
    end
  end

  def send_notification
  end
end
