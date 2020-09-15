class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :address_line, default: ''
      t.integer :locality_id, null: false, index: true
      t.integer :city_id, null: false, index: true
      t.string :landmark, default: ''
      t.string :phone_no, default: ''
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.integer :user_id, index: true
      t.string :tag, default: ''
      t.string :status, default: 'active'

      t.timestamps null: false
    end
  end
end
