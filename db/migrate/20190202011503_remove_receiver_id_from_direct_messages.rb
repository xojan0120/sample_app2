class RemoveReceiverIdFromDirectMessages < ActiveRecord::Migration[5.1]
  def change
    remove_column :direct_messages, :receiver_id, :string
  end
end
