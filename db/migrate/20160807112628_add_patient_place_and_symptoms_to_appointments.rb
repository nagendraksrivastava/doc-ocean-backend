class AddPatientPlaceAndSymptomsToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :patient_place, :boolean, default: false
    add_column :appointments, :symptoms, :string
  end
end
