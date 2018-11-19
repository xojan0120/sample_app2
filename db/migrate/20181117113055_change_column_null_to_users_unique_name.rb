class ChangeColumnNullToUsersUniqueName < ActiveRecord::Migration[5.1]
  def change
    change_column_null :users, :unique_name, false
  end
end
