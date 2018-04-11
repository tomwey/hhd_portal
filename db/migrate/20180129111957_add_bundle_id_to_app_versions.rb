class AddBundleIdToAppVersions < ActiveRecord::Migration
  def change
    add_column :app_versions, :bundle_id, :string
  end
end
