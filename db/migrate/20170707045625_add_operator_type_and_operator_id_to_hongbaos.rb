class AddOperatorTypeAndOperatorIdToHongbaos < ActiveRecord::Migration
  def change
    add_column :hongbaos, :operator_type, :string
    add_column :hongbaos, :operator_id, :integer
    add_index :hongbaos, :operator_type
    add_index :hongbaos, [:operator_type, :operator_id]
  end
end
