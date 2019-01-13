require 'rails_helper'

RSpec.describe Micropost, type: :model do
  it "ユーザに紐付いていれば有効であること" do
    #user = FactoryBot.create(:user)
    #micropost = user.microposts.build(content: "test")
    micropost = FactoryBot.create(:micropost)
    expect(micropost).to be_valid
  end

  it "ユーザに紐付いていなければ無効であること" do
    #user = FactoryBot.create(:user)
    #micropost = user.microposts.build(content: "test")
    micropost = FactoryBot.create(:micropost)
    micropost.user_id = nil
    expect(micropost).to be_invalid
  end

  it "投稿があれば有効であること" do
    micropost = FactoryBot.build(:micropost)
    expect(micropost).to be_valid
  end

  it "投稿がなければ無効であること" do
    micropost = FactoryBot.build(:micropost, content:nil)
    expect(micropost).to be_invalid
  end

  it "投稿が140文字以下なら有効であること" do
    micropost = FactoryBot.build(:micropost, content: "a"*140)
    expect(micropost).to be_valid
  end

  it "投稿が141文字以上なら無効であること" do
    micropost = FactoryBot.build(:micropost, content: "a"*141)
    expect(micropost).to be_invalid
  end

  it "投稿は作成日時の新しいものから取得できること" do
    user = FactoryBot.create(:user)
    micropost1 = user.microposts.create(content: "test1", created_at: Date.yesterday.to_time)
    micropost2 = user.microposts.create(content: "test2", created_at: Date.today.to_time)
    micropost3 = user.microposts.create(content: "test3", created_at: Date.yesterday.to_time)
    expect(user.microposts.first.created_at).to eq Date.today.to_time
  end
end
