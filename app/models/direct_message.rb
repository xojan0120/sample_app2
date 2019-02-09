class DirectMessage < ApplicationRecord
  belongs_to :user
  has_many   :direct_message_stats
  belongs_to :room

  #validates :content, presence: true
  #validates :content_or_picture, presence: true
  #validates :content_or_pictrue, hoge: true

  # 1.pictureが存在しないとき、contentの存在性を検証する
  validates_presence_of :content, unless: :picture?
  # 2.contentが存在しないとき、pictureの存在性を検証する
  validates_presence_of :picture, unless: :content?
  # 上記の２つの検証は、contentとpictureのいずれかが存在する場合は、パスする
  # つまり、contentとpictureの両方が存在しなに場合は、パスしない

  mount_uploader :picture, PictureUploader

  def get_state_for(user)
    direct_message_stats.find_by(user: user)
  end
end
