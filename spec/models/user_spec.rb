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
    it "自分の投稿が全て取得できる" do
      contents = ["投稿1","投稿2"]
      me = FactoryBot.create(:user)
      FactoryBot.create(:micropost, user: me, content: contents[0])
      FactoryBot.create(:micropost, user: me, content: contents[1])
      expect(me.feed).to match_array(contents)
    end
  end
end
