class RemoveSenderIdFromDirectMessages < ActiveRecord::Migration[5.1]
  def change
    remove_column :direct_messages, :sender_id, :string
  end
end
