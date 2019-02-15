class AddUserToDirectMessages < ActiveRecord::Migration[5.1]
  def change
    add_reference :direct_messages, :user, foreign_key: true
  end
end
