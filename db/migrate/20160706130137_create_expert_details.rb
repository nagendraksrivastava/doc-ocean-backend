class CreateExpertDetails < ActiveRecord::Migration
  def change
    create_table :expert_details do |t|
      t.string :profession
      t.string :license_no
      t.decimal :consulting_fee, precision: 12, scale: 2
      t.integer :user_id, null: false, index: true

      t.timestamps null: false
    end
  end
end
