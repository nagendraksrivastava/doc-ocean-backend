class AddGenderToUsersAndPatients < ActiveRecord::Migration
  def change
    add_column :users, :gender, :string
    add_column :patients, :gender, :string
  end
end
