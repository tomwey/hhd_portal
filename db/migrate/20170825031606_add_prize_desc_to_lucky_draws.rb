class AddPrizeDescToLuckyDraws < ActiveRecord::Migration
  def change
    add_column :lucky_draws, :prize_desc, :text
    add_column :lucky_draws, :memo, :string
  end
end
