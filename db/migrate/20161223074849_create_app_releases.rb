class CreateAppReleases < ActiveRecord::Migration
  def change
    create_table :app_releases do |t|
      t.string :app_version, index: true, null: false
      t.integer :numeric_version, index: true, null: false
      t.boolean :depreciated, default: false
      t.boolean :released, default: false
      t.text :features
      t.string :app_type, null: false

      t.timestamps null: false
    end
  end
end
