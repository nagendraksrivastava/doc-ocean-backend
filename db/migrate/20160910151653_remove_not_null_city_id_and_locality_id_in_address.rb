class RemoveNotNullCityIdAndLocalityIdInAddress < ActiveRecord::Migration
  def change
    change_column_null(:addresses, :city_id, true)
    change_column_null(:addresses, :locality_id, true)    
  end
end
