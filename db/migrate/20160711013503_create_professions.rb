class CreateProfessions < ActiveRecord::Migration
  def change
    create_table :professions do |t|
      t.string :name, null: false, index: true
      t.boolean :supported, default: true

      t.timestamps null: false
    end
  end
end
