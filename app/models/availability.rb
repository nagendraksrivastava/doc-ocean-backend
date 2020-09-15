class Availability < ActiveRecord::Base
  belongs_to :user
  belongs_to :address

  enum day: {MON: 'MON', TUE: 'TUE', WED: 'WED', THU: 'THU', FRI: 'FRI', SAT: 'SAT', SUN: 'SUN'}
  enum status: {active: 'active', inactive: 'inactive'}
  validates :day, :start_time, :end_time, :user_id, :address_id, presence: true
  validates :start_time, :end_time, overlap: {scope: ["user_id", "day"],
              exclude_edges: [:start_time, :end_time], :query_options => {:active => nil}}
  validate :address_belongs_to_user?

  def address_belongs_to_user?
    unless self.user_id && self.address_id && self.user.addresses.map(&:id).include?(self.address_id)
      errors.add(:base, 'Invalid address')
      false
    end
  end

  def details
    {
      id: id,
      day: day,
      start_time: start_time.strftime("%H:%M"),
      end_time: end_time.strftime("%H:%M"),
      address_id: address_id
    }
  end
end
