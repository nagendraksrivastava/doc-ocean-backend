class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name
      t.string :code
      t.string :status, index: true, default: 'active'
      t.integer :profession_id, index: true

      t.timestamps null: false
    end
  end
end
