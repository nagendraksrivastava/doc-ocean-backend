class CreateExpertServices < ActiveRecord::Migration
  def change
    create_table :expert_services do |t|
      t.string :name
      t.string :status, default: 'active', index: true
      t.integer :profession_id, index: true
      t.integer :category_id, index: true
      t.decimal :cost, precision: 12, scale: 2

      t.timestamps null: false
    end
  end
end
