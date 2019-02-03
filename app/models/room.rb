class Room < ApplicationRecord
  has_many :user_rooms
  has_many :users, through: :user_rooms
  has_many :direct_messages, -> {表示状態のもののみ }

  def self.make(users_array)
    room = Room.create
    users_array.each do |user|
      UserRoom.create(user: user,room: room)
    end
    room
  end

  def self.pick(users_array)
    user_room = UserRoom.where(user_id: users_array.pluck(:id)).select(:room_id).distinct.first
    user_room&.room
  end
end
