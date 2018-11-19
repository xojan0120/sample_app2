class ChangeColumnDefaultCancelToUsersUniqueName < ActiveRecord::Migration[5.1]
  def change
    change_column_default :users, :unique_name, nil
  end
end
