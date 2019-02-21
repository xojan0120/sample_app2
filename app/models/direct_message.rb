class DirectMessage < ApplicationRecord
  belongs_to :user
  has_many   :direct_message_stats, dependent: :destroy
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

  def received_users
    #users = Array.new
    #room.user_rooms.where.not(user: user).each do |user_room|
    #  users << user_room.user
    #end
    #users

    # roomに所属するユーザ群のうち、自分を除くユーザ群を返す
    # ※bulletでUSE eager loading detectedがでるが、問題無し。
    room.users.where.not(id: user.id)
  end
end
