require 'rails_helper'

RSpec.describe DirectMessage, type: :model do

  it "userとroomとcontentがあれば有効な状態であること" do
    user = FactoryBot.create(:user)
    room = FactoryBot.create(:room)
    content = "test message"
    dm = DirectMessage.new(user: user, room: room, content: content)
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

  it "contentがなければ無効な状態であること" do
    user = FactoryBot.create(:user)
    room = FactoryBot.create(:room)
    dm = DirectMessage.new(user: user, room: room)
    expect(dm).to be_invalid
  end

  it "メッセージの表示状態が取得できること" do
    user = FactoryBot.create(:user)
    room = Room.make([user])
    content = "#{user.name}'s message"
    dm = user.send_dm(room, content)
    dm_stat = dm.get_state_for(user)
    expect(dm_stat.display).to be_truthy
  end
end
