class DirectMessage < ApplicationRecord
  belongs_to :user
  has_many :direct_message_stats
  belongs_to :room
end
