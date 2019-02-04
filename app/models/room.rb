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

  def self.pick(users_array)
    UserRoom.identify_room(users_array)
  end

  def self.exist?(users_array)
    UserRoom.identify_room(users_array) ? true : false
  end
end
