class Rating < ActiveRecord::Base
  belongs_to :user
  belongs_to :rated_by, class_name: 'User'
  after_create :clear_user_rating_cache

  validates :value, :user_id, :rated_by_id, :appointment_id, presence: true
  validates :rated_by_id, uniqueness: {scope: [:user_id, :appointment_id],
    message: "You already rated this appointment"}

  private
    def clear_user_rating_cache
      Rails.cache.delete("rating-#{self.user_id}")
    end
end
