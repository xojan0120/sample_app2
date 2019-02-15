require 'rails_helper'

RSpec.describe UserRoom, type: :model do
  it "ユーザとルームがあれば有効な状態であること" do
    user = FactoryBot.create(:user)
    room = FactoryBot.create(:room)
    user_room = UserRoom.new(user: user, room: room)
    expect(room).to be_valid
  end

  it "ユーザがなければ無効な状態であること" do
    room = FactoryBot.create(:room)
    user_room = UserRoom.new(room: room)
    expect(user_room).to be_invalid
  end

  it "ルームがなければ無効な状態であること" do
    user = FactoryBot.create(:user)
    user_room = UserRoom.new(user: user)
    expect(user_room).to be_invalid
  end

  it "あるユーザ群が全員所属するユーザルームを取得できること" do
    user1 = FactoryBot.create(:user)
    user2 = FactoryBot.create(:user)
    room  = FactoryBot.create(:room)
    UserRoom.create(user: user1, room: room)
    UserRoom.create(user: user2, room: room)

    expect(UserRoom.identify_room([user1,user2])).to eq room
  end

  it "所属していないユーザがいる場合はルームを取得できないこと" do
    user1 = FactoryBot.create(:user)
    other = FactoryBot.create(:user)
    room  = FactoryBot.create(:room)
    UserRoom.create(user: user1, room: room)

    expect(UserRoom.identify_room([user1,other])).to be_nil
  end

  it "空のユーザ群を指定した場合はルームが取得できないこと" do
    expect(UserRoom.identify_room([])).to be_nil
  end
end
