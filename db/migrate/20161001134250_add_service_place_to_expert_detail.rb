class AddServicePlaceToExpertDetail < ActiveRecord::Migration
  def change
    add_column :expert_details, :service_place, :string
    add_index :expert_details, :service_place
  end
end
