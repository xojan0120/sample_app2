class DirectMessageStat < ApplicationRecord
  belongs_to :direct_message
  belongs_to :user

  validates :user, presence: true
  validates :direct_message, presence: true

end
