class UserDevice < ActiveRecord::Base
  HASHING_KEY = "!OCE@N-DOC!"
  validates :device_id, :push_notification_reg_id, presence: true, uniqueness: true
  belongs_to :user
  enum status: {'active' => 'active', 'inactive' => 'inactive'}

  def self.valid_checksum?(device_id, checksum)
    Digest::SHA256.base64digest(device_id.to_s + HASHING_KEY) == checksum
  end

  def self.add_or_update_device(user, device_id)
    user_device = find_or_initialize_by(device_id: device_id)
    user_device.user = user
    user_device.status = UserDevice::statuses['active']
    user_device.save!
    user_device.invalidate_other_devices
  end

  def invalidate_other_devices
    devices = UserDevice.where.not(device_id: self.device_id).where(user_id: self.user_id)
    devices.update_all(status: UserDevice::statuses['inactive']) if devices.any?
  end
end
