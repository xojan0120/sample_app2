class UserRoom < ApplicationRecord
  belongs_to :user
  belongs_to :room

  # users_arrayとルームのメンバーが一致するルームを取得する
  # 無い場合はnilを返す
  # 注意：「一致」であり、「含まれる」ではない
  def self.identify_room(users_array)
    if users_array.is_a?(Array) && users_array.count > 0
      # users_arrayのユーザが含まれないroom_idを取得
      r1 = UserRoom.select(:room_id).where.not(user: users_array)
      # r1のroom_id以外のroomのroom_idを取得
      r2 = UserRoom.select(:room_id).where.not(room_id: r1)
      # r2で取得できたroom_idの数(=メンバー数)とusers_arrayの数が一致すれば、そのルームを返す
      if r2.count == users_array.count
        r2.distinct.first.room
      end
      #debugger
    end
  end
end
