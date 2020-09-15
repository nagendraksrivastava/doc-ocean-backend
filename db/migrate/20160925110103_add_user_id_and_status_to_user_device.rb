class AddUserIdAndStatusToUserDevice < ActiveRecord::Migration
  def change
    add_column :user_devices, :user_id, :integer, index: true
    add_column :user_devices, :status, :string, default: 'active', index: true
  end
end
