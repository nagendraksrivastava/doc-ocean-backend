class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :name, index: true, null: false
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.string :status, index: true, default: 'active'

      t.timestamps null: false
    end
  end
end
