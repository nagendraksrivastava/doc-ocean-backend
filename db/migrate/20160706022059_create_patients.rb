class CreatePatients < ActiveRecord::Migration
  def change
    create_table :patients do |t|
      t.string :name, null: false, default: ""
      t.date :date_of_birth, null: false
      t.string :phone_no
      t.integer :user_id, null: false
      t.boolean :myself, default: false

      t.timestamps null: false
      t.index [:user_id]
    end
  end
end
