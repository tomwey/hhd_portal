class AddWinScoreToRedbags < ActiveRecord::Migration
  def change
    add_column :redbags, :win_score, :integer
  end
end
