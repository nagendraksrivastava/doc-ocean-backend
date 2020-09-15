class AddDateOfBirthLoginStatusAndGcmRegIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :date_of_birth, :date
    add_column :users, :login_status, :string
    add_column :users, :gcm_reg_id, :string
  end
end
