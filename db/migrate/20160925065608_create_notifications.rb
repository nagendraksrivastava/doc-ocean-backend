class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :code
      t.references :notifiable, polymorphic: true, index: true
      t.integer :user_id
      t.string :status
      t.text :data
      t.string :type

      t.timestamps null: false
    end
  end
end
