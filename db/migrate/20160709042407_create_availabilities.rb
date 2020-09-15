class CreateAvailabilities < ActiveRecord::Migration
  def change
    create_table :availabilities do |t|
      t.string :day
      t.time :start_time
      t.time :end_time
      t.integer :address_id, null: false, index: true
      t.integer :user_id, null: false, index: true
      t.string :status, null: false, default: 'active'

      t.timestamps null: false
    end
  end
end
