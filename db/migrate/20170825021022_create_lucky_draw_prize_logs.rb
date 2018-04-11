class CreateLuckyDrawPrizeLogs < ActiveRecord::Migration
  def change
    create_table :lucky_draw_prize_logs do |t|
      t.string :uniq_id
      t.references :user, index: true, foreign_key: true
      t.references :lucky_draw, index: true, foreign_key: true
      t.integer :prize_id # 奖项id
      t.string :ip
      t.st_point :location, geographic: true

      t.timestamps null: false
    end
    
    add_index :lucky_draw_prize_logs, :uniq_id, unique: true
    add_index :lucky_draw_prize_logs, :prize_id
    add_index :lucky_draw_prize_logs, :location, using: :gist
    add_index :lucky_draw_prize_logs, [:user_id, :lucky_draw_id]
  end
end
