class ChangeIntegerSenderIdOfDirectMessages < ActiveRecord::Migration[5.1]
  def up
    change_column :direct_messages, :sender_id, :integer
  end
  def down
    change_column :direct_messages, :sender_id, :string
  end
end
