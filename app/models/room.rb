class Room < ApplicationRecord
  has_many :user_rooms
  has_many :users, through: :user_rooms
  has_many :direct_messages , -> { order(:created_at) } 

  # ルームのメッセージを取得する
  # 但し、userに指定したユーザが非表示にしたものは除く
  def direct_messages_for(user)
    r1 = direct_messages.joins(:direct_message_stats)
    r2 = DirectMessageStat.where(user: user, display: true)
    r1.merge(r2)
  end

  def self.make(users_array)
    room = Room.create
    users_array.each do |user|
      UserRoom.create(user: user,room: room)
    end
    room
  end

  # users_arrayの全ユーザが所属しているルームのみ取得する
  # 無い場合はnilを返す
  def self.pick(users_array)
    user_room = UserRoom.where(user_id: users_array.pluck(:id)).select(:room_id).distinct.first
    user_room&.room
  end
end
