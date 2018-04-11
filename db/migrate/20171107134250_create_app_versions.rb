class CreateAppVersions < ActiveRecord::Migration
  def change
    create_table :app_versions do |t|
      t.string :version, null: false, default: ''
      t.text :change_log, null: false, default: ''
      t.string :os, null: false, default: ''
      t.string :app_file
      t.string :app_download_url
      t.boolean :must_upgrade, default: false
      t.boolean :opened, default: false

      t.timestamps null: false
    end
    add_index :app_versions, :version
  end
end
