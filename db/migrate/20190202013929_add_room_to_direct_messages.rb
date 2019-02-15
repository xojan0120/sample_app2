class AddRoomToDirectMessages < ActiveRecord::Migration[5.1]
  def change
    add_reference :direct_messages, :room, foreign_key: true
  end
end
