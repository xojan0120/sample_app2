require 'rails_helper'

RSpec.describe DirectMessage, type: :model do

  it "userとroomがあれば有効な状態であること" do
    user = FactoryBot.create(:user)
    room = FactoryBot.create(:room)
    dm = DirectMessage.new(user: user, room: room)
    expect(dm).to be_valid
  end

  it "userがなければ無効な状態であること" do
    room = FactoryBot.create(:room)
    dm = DirectMessage.new(room: room)
    expect(dm).to be_invalid
  end

  it "roomがなければ無効な状態であること" do
    user = FactoryBot.create(:user)
    dm = DirectMessage.new(user: user)
    expect(dm).to be_invalid
  end

  xit "2人のユーザのメッセージが取得できる" do
    user1 = FactoryBot.create(:user)
    user2 = FactoryBot.create(:user)
    pair_user_id = [user1.id, user2.id]

    user1.send_dm("my name is #{user1.name}", user2)
    user2.send_dm("my name is #{user2.name}", user1)
    dms = [user1.sent_direct_messages.first, user2.sent_direct_messages.first]

    expect(DirectMessage.get_dm(pair_user_id)).to match_array(dms)
  end

end
