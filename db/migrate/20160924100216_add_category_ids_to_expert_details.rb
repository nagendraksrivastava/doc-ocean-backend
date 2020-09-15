class AddCategoryIdsToExpertDetails < ActiveRecord::Migration
  def change
    add_column :expert_details, :category_ids, :string, array: true, default: []
  end
end
