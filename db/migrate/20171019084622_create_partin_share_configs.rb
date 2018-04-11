class CreatePartinShareConfigs < ActiveRecord::Migration
  def change
    create_table :partin_share_configs do |t|
      t.string :icon
      t.string :title
      t.references :winnable, polymorphic: true, index: true
      t.references :partin, index: true, null: false

      t.timestamps null: false
    end
  end
end
