class Room < ApplicationRecord
  has_many :user_rooms, dependent: :delete_all
  has_many :users, through: :user_rooms
  has_many :direct_messages, -> { order(created_at: :asc) }, dependent: :delete_all

  # ルームのメッセージを取得する
  # 但し、userに指定したユーザが非表示にしたものは除く
  def direct_messages_for(user, page: nil, cnt: nil)
    messages = fetch_messages_for(user)

    if page.present? || cnt.present?
      ofs = (page - 1) * cnt
      messages.offset(ofs).last(cnt)
    else
      messages
    end
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

  def self.find_or_make_by(users_array)
    Room.exist?(users_array) ? Room.pick(users_array) : Room.make(users_array)
  end

  private

    def fetch_messages_for(user)
      r1 = direct_messages.joins(:direct_message_stats).includes(:user)
      r2 = DirectMessageStat.where(user: user, display: true)
      r1.merge(r2)
    end
end
