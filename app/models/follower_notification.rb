class FollowerNotification < ApplicationRecord
  belongs_to :user
  has_many :logs, class_name: 'FollowerNotificationLog', dependent: :destroy

  validates :enabled, inclusion: { in: [true, false] }
end
