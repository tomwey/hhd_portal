class AddEventIdToQuizRules < ActiveRecord::Migration
  def change
    add_column :quiz_rules, :event_id, :integer
    add_index :quiz_rules, :event_id
  end
end
