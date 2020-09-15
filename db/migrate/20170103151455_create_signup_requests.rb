class CreateSignupRequests < ActiveRecord::Migration
  def change
    create_table :signup_requests do |t|
      t.string :full_name
      t.string :email
      t.string :mobile
      t.string :profession
      t.string :status

      t.timestamps null: false
    end
  end
end
