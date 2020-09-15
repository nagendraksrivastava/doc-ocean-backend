class CreateUserDevices < ActiveRecord::Migration
  def change
    remove_column :users, :gcm_reg_id
    create_table :user_devices do |t|
      t.string :device_id, null: false
      t.string :push_notification_reg_id, null: false

      t.timestamps null: false
    end
  end
end
