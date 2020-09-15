class CreateOptedExpertServices < ActiveRecord::Migration
  def change
    create_table :opted_expert_services do |t|
      t.integer :service_id
      t.string :service_name
      t.decimal :cost, precision: 12, scale: 2
      t.integer :appointment_id, inex: true

      t.timestamps null: false
    end
  end
end
