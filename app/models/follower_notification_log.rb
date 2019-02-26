class FollowerNotificationLog < ApplicationRecord
  belongs_to :follower_notification
  belongs_to :follower, class_name: 'User'

  validates :follower_id,           presence: true
  validates :mail_sent_at,          presence: true
  validates :follower_notification, presence: true

  def self.create_or_update(follow_user, followed_user, time = Time.zone.now)
    if log = find_by(follower:              follow_user,
										 follower_notification: followed_user.follower_notification
										)
      log.update_attribute(:mail_sent_at, time)
    else
      create(follower:              follow_user,
             mail_sent_at:          time,
             follower_notification: followed_user.follower_notification
            )
    end
  end
end
