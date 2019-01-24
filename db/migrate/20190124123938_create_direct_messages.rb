class CreateDirectMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :direct_messages do |t|
      t.string :content
      t.string :sender_id
      t.string :receiver_id
      t.boolean :sender_display
      t.boolean :receiver_display
      t.string :picture

      t.timestamps
    end
  end
end
