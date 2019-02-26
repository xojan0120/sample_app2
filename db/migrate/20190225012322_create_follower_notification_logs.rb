class CreateFollowerNotificationLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :follower_notification_logs do |t|
      t.integer :follower_id
      t.datetime :mail_sent_at
      t.references :follower_notification, foreign_key: true

      t.timestamps
    end
  end
end
