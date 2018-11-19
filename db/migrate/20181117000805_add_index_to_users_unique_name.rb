class AddIndexToUsersUniqueName < ActiveRecord::Migration[5.1]
  def change
    add_index :users, :unique_name, unique: true
  end
end
