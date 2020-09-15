class AddAuthTokenTypeAndMobileNoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :auth_token, :string
    add_column :users, :type, :string, index: true, null: false
    add_column :users, :phone_no, :string, index: true, null: false
    add_index :users, :auth_token, unique: true
    add_index :users, [:type, :email, :phone_no], unique: true
  end
end
