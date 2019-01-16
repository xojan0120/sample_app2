require 'rails_helper'

RSpec.describe Reply, type: :model do
  it "投稿に紐付いていれば有効であること" do
    reply = FactoryBot.build(:reply)
    expect(reply).to be_valid
  end

  it "投稿に紐付いていなければ無効であること" do
    reply = FactoryBot.build(:reply)
    reply.micropost_id = nil
    expect(reply).to be_invalid
  end

  it "返信先があれば有効であること" do
    reply = FactoryBot.build(:reply, reply_to: 1)
    debugger
    expect(reply).to be_valid
  end

  it "返信先がなければ無効であること" do
    reply = FactoryBot.build(:reply, reply_to: nil)
    expect(reply).to be_invalid
  end
end
