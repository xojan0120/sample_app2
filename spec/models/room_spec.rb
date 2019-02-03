require 'rails_helper'

RSpec.describe Room, type: :model do
  it "有効な状態であること" do
    room = Room.new
    expect(room).to be_valid
  end

  it "ルームを作成できること" do
    users = FactoryBot.create_list(:user, 2)
    expect {
      Room.make(users)
    }.to change(Room, :count).by(1)
  end

  it "ルームを取得できること" do
    users = FactoryBot.create_list(:user, 2)
    Room.make(users)

    room = Room.pick(users)

    expect(room.users).to match_array(users)
  end

  fit "ルームのメッセージを取得できること" do
    user1 = FactoryBot.create(:user)
    user2 = FactoryBot.create(:user)
    users = [user1,user2]

    room = Room.make(users)

    content1 = "#{user1.name}'s message"
    content2 = "#{user2.name}'s message"

    user1.send_dm(room, content1)
    user2.send_dm(room, content2)

    expect(room.direct_messages.pluck(:content)).to match_array([content1,content2])
  end

end
