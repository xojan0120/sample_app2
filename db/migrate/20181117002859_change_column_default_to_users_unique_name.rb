class ChangeColumnDefaultToUsersUniqueName < ActiveRecord::Migration[5.1]
  def change
    change_column_default :users, :unique_name, ""
  end
end
