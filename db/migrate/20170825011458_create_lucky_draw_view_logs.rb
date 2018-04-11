class CreateLuckyDrawViewLogs < ActiveRecord::Migration
  def change
    create_table :lucky_draw_view_logs do |t|
      t.references :lucky_draw, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.string :ip
      t.st_point :location, geographic: true

      t.timestamps null: false
    end
    add_index :lucky_draw_view_logs, :location, using: :gist
  end
end
