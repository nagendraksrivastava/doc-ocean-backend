class CreateAppointments < ActiveRecord::Migration
  def change
    create_table :appointments do |t|
      t.string :number, null: false, index: true
      t.integer :patient_id, null: false, index: true
      t.integer :expert_detail_id, null: false, index: true
      t.integer :patient_address_id, null: false
      t.integer :expert_address_id
      t.string :status, null: false, index: true
      t.datetime :confirmed_at
      t.datetime :scheduled_at, index: true
      t.text :instructions

      t.timestamps null: false
    end
  end
end
