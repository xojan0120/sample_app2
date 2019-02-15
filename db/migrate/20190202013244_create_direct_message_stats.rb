class CreateDirectMessageStats < ActiveRecord::Migration[5.1]
  def change
    create_table :direct_message_stats do |t|
      t.references :direct_message, foreign_key: true
      t.references :user, foreign_key: true
      t.boolean :display

      t.timestamps
    end
  end
end
