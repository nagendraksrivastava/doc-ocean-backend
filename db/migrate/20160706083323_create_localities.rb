class CreateLocalities < ActiveRecord::Migration
  def change
    create_table :localities do |t|
      t.string :name, index: true, null: false
      t.decimal :latitude, precision: 10, scale: 6, null: false
      t.decimal :longitude, precision: 10, scale: 6, null: false
      t.integer :city_id, index: true, null: false
      t.string :status, index: true, default: 'active'

      t.timestamps null: false
    end
  end
end
