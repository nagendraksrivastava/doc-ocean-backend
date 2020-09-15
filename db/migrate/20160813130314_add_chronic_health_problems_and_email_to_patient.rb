class AddChronicHealthProblemsAndEmailToPatient < ActiveRecord::Migration
  def change
    add_column :patients, :chronic_health_problems, :text
    add_column :patients, :email, :string
  end
end
