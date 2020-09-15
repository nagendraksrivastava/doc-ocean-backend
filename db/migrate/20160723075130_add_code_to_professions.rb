class AddCodeToProfessions < ActiveRecord::Migration
  def change
    add_column :professions, :code, :string, null: false
    add_index :professions, :code
  end
end
