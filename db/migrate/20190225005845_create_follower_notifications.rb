class CreateFollowerNotifications < ActiveRecord::Migration[5.1]
  def change
    create_table :follower_notifications do |t|
      t.boolean :enabled
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
