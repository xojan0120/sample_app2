require 'rails_helper'

RSpec.describe UserRoom, type: :model do
  it "userとroomがあれば有効な状態であること" do
    user = FactoryBot.create(:user)
    room = FactoryBot.create(:room)
    user_room = UserRoom.new(user: user, room: room)
    expect(room).to be_valid
  end

  it "userがなければ無効な状態であること" do
    room = FactoryBot.create(:room)
    user_room = UserRoom.new(room: room)
    expect(user_room).to be_invalid
  end

  it "roomがなければ無効な状態であること" do
    user = FactoryBot.create(:user)
    user_room = UserRoom.new(user: user)
    expect(user_room).to be_invalid
  end
end
