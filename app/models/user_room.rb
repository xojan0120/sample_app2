class UserRoom < ApplicationRecord
  belongs_to :user
  belongs_to :room

  # users_arrayとルームのメンバーが一致するルームを取得する
  # 無い場合はnilを返す
  # 注意：「一致」であり、「含まれる」ではない
  #
  # [ルームの特定方法]
  # 例)
  # users_array = [1,2,3] とする。
  # UserRoomのデータは下記とする
  #   user_id:1, room_id:1 o
  #   user_id:2, room_id:1 o
  #   user_id:3, room_id:1 o
  # 
  #   user_id:1, room_id:2 o
  #   user_id:2, room_id:2 o
  # 
  #   user_id:4, room_id:3 x
  # 
  # room_id:1と2が取得候補となる。これらの候補のうち、
  # users_arrayのメンバー数と一致するものが対象である。
  def self.identify_room(users_array)
    if users_array.is_a?(Array) && users_array.count > 0
      # users_arrayのメンバーを含むルームを取得し、
      # room_id毎にそのルームのメンバー数を集計する。
      r1 = UserRoom.where(user: users_array).group(:room_id).count

      # users_arrayのメンバー数と、上記で取得したルームのメンバー数が
      # 一致するものを返す
      result_room = nil
      r1.each do |room_id, member_count|
        if member_count == users_array.count
          result_room = Room.find(room_id)
          break
        end
      end

      result_room
    end
  end
end
