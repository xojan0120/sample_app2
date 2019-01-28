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
end
