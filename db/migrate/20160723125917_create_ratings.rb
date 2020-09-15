class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer :value
      t.integer :user_id, index: true
      t.integer :rated_by_id
      t.integer :appointment_id, index: true

      t.timestamps null: false
    end
  end
end
