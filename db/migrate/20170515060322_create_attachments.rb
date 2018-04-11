class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string :uniq_id
      t.references :attachmentable, polymorphic: true, index: true
      t.references :ownerable, polymorphic: true, index: true
      t.string :data_file_name
      t.string :data_content_type
      t.integer :data_file_size
      t.integer :width
      t.integer :height

      t.timestamps null: false
    end
    add_index :attachments, :uniq_id, unique: true
  end
end
