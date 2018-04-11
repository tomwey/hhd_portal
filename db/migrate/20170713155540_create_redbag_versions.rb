class CreateRedbagVersions < ActiveRecord::Migration
  def change
    create_table :redbag_versions do |t|
      t.references :redbag, index: true, foreign_key: true
      t.json :value, null: false
      t.string :uniq_id

      t.timestamps null: false
    end
    add_index :redbag_versions, :uniq_id, unique: true
  end
end
