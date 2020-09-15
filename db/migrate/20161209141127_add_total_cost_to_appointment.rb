class AddTotalCostToAppointment < ActiveRecord::Migration
  def change
    add_column :appointments, :total_cost, :decimal, precision: 12, scale: 2
  end
end
