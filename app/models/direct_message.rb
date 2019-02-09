class DirectMessage < ApplicationRecord
  belongs_to :user
  has_many   :direct_message_stats
  belongs_to :room

  # 1.pictureが存在しないとき、contentの存在性を検証する
  validates_presence_of :content, unless: :picture?
  # 2.contentが存在しないとき、pictureの存在性を検証する
  validates_presence_of :picture, unless: :content?
  # 上記の２つの検証は、contentとpictureのいずれかが存在する場合は、パスする
  # つまり、contentとpictureの両方が存在しなに場合は、パスしない

  mount_uploader :picture, PictureUploader
  validates :picture_data_uri, size: { maximum: 5.megabytes }, if: :picture?

  def get_state_for(user)
    direct_message_stats.find_by(user: user)
  end
end
