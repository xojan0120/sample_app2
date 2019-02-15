class ChangeIntegerReceiverIdOfDirectMessages < ActiveRecord::Migration[5.1]
  def up
    change_column :direct_messages, :receiver_id, :integer
  end
  def down
    change_column :direct_messages, :receiver_id, :string
  end
end
