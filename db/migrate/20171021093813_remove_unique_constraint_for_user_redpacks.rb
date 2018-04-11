class RemoveUniqueConstraintForUserRedpacks < ActiveRecord::Migration
  def change
    remove_index :user_redpacks, [:user_id, :redpack_id]#, unique: true
  end
end
