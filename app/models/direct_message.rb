class DirectMessage < ApplicationRecord
  belongs_to :user
  has_many :direct_message_stats
  belongs_to :room

  validates :content, presence: true

  mount_uploader :picture, PictureUploader

  def get_state_for(user)
    direct_message_stats.find_by(user: user)
  end
end
