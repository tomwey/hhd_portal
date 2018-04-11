class AddMerchantIdToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :merchant_id, :integer
    add_index :questions, :merchant_id
  end
end
