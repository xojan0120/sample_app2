require 'rails_helper'

RSpec.describe User, type: :model do
  #it "管理者でないユーザ" do
  #  user = FactoryBot.create(:user, :not_admin)
  #  expect(user.admin).to be_falsey
  #end

  #it "メールアドレスを全て小文字にする" do
  #  test_address = "John_Smith@Example.com"
  #  user = FactoryBot.create(:user, email: test_address)
  #  expect(user.email).to eq test_address.downcase
  #end

  it "ユニークネームは全て小文字である" do
    unique_name = "John_Smith"
    user = FactoryBot.create(:user, unique_name: unique_name)
    expect(user.unique_name).to eq unique_name.downcase
  end

  describe "フィード機能について" do
    it "内部でMicropost.including_repliesが呼ばれている" do
      me = FactoryBot.create(:user)
      expect(Micropost).to receive(:including_replies).with(me.id)
      me.feed
    end
  end

  describe "フォローユーザ検索機能について" do
    let(:me) { FactoryBot.create(:user) }

    context "ユーザ名でヒットした場合" do
      it "ユーザの配列を返す" do
        match_user1  = FactoryBot.create(:user, name: "John Smith", unique_name: "other1")
        match_user2  = FactoryBot.create(:user, name: "Jane Smith", unique_name: "other2")
        unmatch_user = FactoryBot.create(:user, name: "MessiahNeo", unique_name: "other3")

        me.follow(match_user1)
        me.follow(match_user2)
        me.follow(unmatch_user)

        result_users = me.following_search("smith")
        expect(result_users).to match_array([match_user1, match_user2])
      end
    end

    context "一意ユーザ名でヒットした場合" do
      it "ユーザの配列を返す" do
        match_user1  = FactoryBot.create(:user, name: "other1", unique_name: "John_Smith")
        match_user2  = FactoryBot.create(:user, name: "other2", unique_name: "Jane_Smith")
        unmatch_user = FactoryBot.create(:user, name: "other3", unique_name: "MessiahNeo")

        me.follow(match_user1)
        me.follow(match_user2)
        me.follow(unmatch_user)

        result_users = me.following_search("smith")
        expect(result_users).to match_array([match_user1, match_user2])
      end
    end

    context "ユーザ名と一意ユーザ名の両方でヒットした場合" do
      it "ユーザの配列を返す" do
        match_user1  = FactoryBot.create(:user, name: "John Smith", unique_name: "John_Smith")
        match_user2  = FactoryBot.create(:user, name: "Jane Smith", unique_name: "Jane_Smith")
        unmatch_user = FactoryBot.create(:user, name: "MessiahNeo", unique_name: "MessiahNeo")

        me.follow(match_user1)
        me.follow(match_user2)
        me.follow(unmatch_user)

        result_users = me.following_search("smith")
        expect(result_users).to match_array([match_user1, match_user2])
      end
    end

    context "ユーザ名と一意ユーザ名の両方でヒットしなかった場合" do
      it "空のユーザの配列を返す" do
        unmatch_user1 = FactoryBot.create(:user, name: "John Smith", unique_name: "John_Smith")
        unmatch_user2 = FactoryBot.create(:user, name: "Jane Smith", unique_name: "Jane_Smith")
        unmatch_user3 = FactoryBot.create(:user, name: "MessiahNeo", unique_name: "MessiahNeo")

        me.follow(unmatch_user1)
        me.follow(unmatch_user2)
        me.follow(unmatch_user3)

        result_users = me.following_search("trinity")
        expect(result_users).to be_empty
      end
    end
  end

  #describe "メッセージ機能について" do
  #  it "ユーザは複数のメッセージを持てる" do
  #    user = FactoryBot.create(:user)
  #    room = FactoryBot.create(:room)
  #    dm1 = user.direct_messages.create(content: "test message1", user: user, room: room)
  #    dm2 = user.direct_messages.create(content: "test message2", user: user, room: room)
  #    expect(user.direct_messages).to match_array([dm1,dm2])
  #  end

  #  it "ユーザはuser_roomsを通して複数のRoomを持てる" do
  #    user = FactoryBot.create(:user)
  #    room1 = FactoryBot.create(:room)
  #    room2 = FactoryBot.create(:room)
  #    user.user_rooms.create(user: user, room: room1)
  #    user.user_rooms.create(user: user, room: room2)
  #    expect(user.rooms).to match_array([room1,room2])
  #  end

  #  it "ユーザは複数のメッセージの状態を持てる" do
  #    user = FactoryBot.create(:user)
  #    st1 = user.direct_message_stats.create()
  #    st2 = user.direct_message_stats.create()
  #    expect(user.direct_message_stats).to match_array([st1,st2])
  #  end
  #end

  xdescribe "メッセージ機能について" do
    let(:me)    { FactoryBot.create(:user) }
    let(:other) { FactoryBot.create(:user) }
    let(:msg1)  { "this is send message1" }
    let(:msg2)  { "this is send message2" }

    it "自分のメッセージを取得できる" do
      me.send_dm(msg1, other)
      me.send_dm(msg2, other)
      expect(me.sent_direct_messages.pluck(:content)).to match_array([msg1,msg2])
    end

    it "相手のメッセージを取得できる" do
      other.send_dm(msg1, me)
      other.send_dm(msg2, me)
      expect(me.received_direct_messages.pluck(:content)).to match_array([msg1,msg2])
    end

    context "自分のメッセージを削除(非表示)した場合" do
      it "相手のメッセージは取得できるが、自分のメッセージは取得できない" do
        my_dm_id    = me.send_dm(msg1, other)
        other_dm_id = other.send_dm(msg2, me)

        # ここで取得できるのは自分が送ったメッセージ
        me.sent_direct_messages.first.hide(:sender)

        sent_dms     = me.sent_direct_messages
        received_dms = me.received_direct_messages

        expect(sent_dms).to         be_empty
        expect(received_dms).to_not be_empty
      end
    end

    context "相手のメッセージを削除(非表示)した場合" do
      fit "自分のメッセージは取得できるが、相手のメッセージは取得できない" do
        my_dm_id    = me.send_dm(msg1, other)
        other_dm_id = other.send_dm(msg2, me)

        # ここで取得できるのは送信者、つまり自分の送ったメッセージ
        me.received_direct_messages.first.hide(:sender)

        sent_dms     = me.sent_direct_messages
        received_dms = me.received_direct_messages

        expect(sent_dms).to_not be_empty
        expect(received_dms).to be_empty
      end
    end
  end

end
