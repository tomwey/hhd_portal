class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.references :likeable, polymorphic: true, index: true
      t.references :user, index: true, foreign_key: true
      t.st_point :location, geographic: true
      t.string :ip

      t.timestamps null: false
    end
    add_index :likes, :location, using: :gist
  end
end
