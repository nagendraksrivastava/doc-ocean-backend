class AddRelationshipToPatient < ActiveRecord::Migration
  def change
    add_column :patients, :relationship, :string
  end
end
