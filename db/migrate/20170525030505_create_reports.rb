class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.references :event, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.string :content, null: false, default: ''
      t.string :ip
      t.st_point :location, geographic: true

      t.timestamps null: false
    end
    add_index :reports, :location, using: :gist
  end
end
