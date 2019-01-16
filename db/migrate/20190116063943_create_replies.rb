class CreateReplies < ActiveRecord::Migration[5.1]
  def change
    create_table :replies do |t|
      t.integer :reply_to
      t.references :micropost, foreign_key: true

      t.timestamps
    end
  end
end
