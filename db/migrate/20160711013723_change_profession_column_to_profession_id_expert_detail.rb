class ChangeProfessionColumnToProfessionIdExpertDetail < ActiveRecord::Migration
  def change
    add_column :expert_details, :profession_id, :integer, index: true
    remove_column :expert_details, :profession
  end
end
