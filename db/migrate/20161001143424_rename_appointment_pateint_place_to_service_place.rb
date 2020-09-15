class RenameAppointmentPateintPlaceToServicePlace < ActiveRecord::Migration
  def change
    remove_column :appointments, :patient_place
    add_column :appointments, :service_place, :string, default: ""
  end
end
