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

  it "ルームの存在確認ができること" do
    users = FactoryBot.create_list(:user, 2)
    other = FactoryBot.create(:user)
    Room.make(users)

    expect(Room.exist?(users)).to be_truthy
    expect(Room.exist?(users << other)).to be_falsey
  end

  it "ルームのメッセージを全て取得できること" do
    user1 = FactoryBot.create(:user)
    user2 = FactoryBot.create(:user)
    users = [user1,user2]

    room = Room.make(users)

    dm1 = user1.send_dm(room, "#{user1.name}'s message")
    dm2 = user2.send_dm(room, "#{user2.name}'s message")

    expect(room.direct_messages_for(user1)).to match_array([dm1,dm2])
    expect(room.direct_messages_for(user2)).to match_array([dm1,dm2])
  end

  it "ルームの非表示状態のメッセージは取得できないこと" do
    user1 = FactoryBot.create(:user)
    user2 = FactoryBot.create(:user)
    users = [user1,user2]

    room = Room.make(users)

    dm1 = user1.send_dm(room, "#{user1.name}'s message")
    dm2 = user2.send_dm(room, "#{user2.name}'s message")

    user1.hide_dm(dm1)

    expect(room.direct_messages_for(user1)).to match_array([dm2])
  end

  it "ルームから取得したメッセージは送信(作成)日時の昇順であること" do
    user1 = FactoryBot.create(:user)
    user2 = FactoryBot.create(:user)
    users = [user1,user2]

    room = Room.make(users)

    dm2 = user2.send_dm(room, "#{user2.name}'s message")
    dm1 = user1.send_dm(room, "#{user1.name}'s message")

    expect(room.direct_messages_for(user1)).to match([dm2,dm1])
  end

  it "ルームを検索して、あれば取得すること" do
    user1 = FactoryBot.create(:user)
    user2 = FactoryBot.create(:user)
    users = [user1,user2]
    room = Room.make(users)

    expect(Room.find_or_make_by(users)).to eq room
  end

  it "ルームを検索して、無ければ作成すること" do
    user1 = FactoryBot.create(:user)
    user2 = FactoryBot.create(:user)
    users = [user1,user2]
    made_room = Room.find_or_make_by(users)
    expect(made_room.users).to match_array(users)
  end

  it "ルームからページ毎にメッセージが取得できること" do
    user1 = FactoryBot.create(:user)
    user2 = FactoryBot.create(:user)
    users = [user1,user2]
    room = Room.make(users)

    dms = []
    10.times do |i|
      dms << user1.send_dm(room, "message#{i}")
    end

    # 5～10件目
    expect(
      room.direct_messages_for(user1, page: 1, cnt: 5)
    ).to match(dms[5..9])

    # 1～5件目
    expect(
      room.direct_messages_for(user1, page: 2, cnt: 5)
    ).to match(dms[0..4])
  end

end
