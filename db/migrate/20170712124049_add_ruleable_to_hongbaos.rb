class AddRuleableToHongbaos < ActiveRecord::Migration
  def change
    add_reference :hongbaos, :ruleable, polymorphic: true, index: true
  end
end
