class RemoveReceiverDisplayFromDirectMessages < ActiveRecord::Migration[5.1]
  def change
    remove_column :direct_messages, :receiver_display, :string
  end
end
