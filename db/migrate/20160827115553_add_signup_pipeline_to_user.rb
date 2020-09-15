class AddSignupPipelineToUser < ActiveRecord::Migration
  def change
    add_column :users, :signup_pipeline, :string
  end
end
