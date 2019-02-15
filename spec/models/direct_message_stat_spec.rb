require 'rails_helper'

RSpec.describe DirectMessageStat, type: :model do
  it "ユーザとメッセージがあれば有効な状態であること" do
    user = FactoryBot.create(:user)
    dm = FactoryBot.create(:direct_message)
    dm_stat = DirectMessageStat.new(user: user, direct_message: dm)
    expect(dm_stat).to be_valid
  end

  it "ユーザがなければ無効な状態であること" do
    dm = FactoryBot.create(:direct_message)
    dm_stat = DirectMessageStat.new(direct_message: dm)
    expect(dm_stat).to be_invalid
  end

  it "メッセージがなければ無効な状態であること" do
    user = FactoryBot.create(:user)
    dm_stat = DirectMessageStat.new(user: user)
    expect(dm_stat).to be_invalid
  end

  it "状態を表示に設定できること" do
    user = FactoryBot.create(:user)
    dm = FactoryBot.create(:direct_message)
    dm_stat = DirectMessageStat.new(user: user, direct_message: dm, display: false)
    expect {
      dm_stat.visible
    }.to change {
      dm_stat.display
    }.from(be_falsey).to(be_truthy)
  end

  it "状態を非表示に設定できること" do
    user = FactoryBot.create(:user)
    dm = FactoryBot.create(:direct_message)
    dm_stat = DirectMessageStat.new(user: user, direct_message: dm, display: true)
    expect {
      dm_stat.invisible
    }.to change {
      dm_stat.display
    }.from(be_truthy).to(be_falsey)
  end

end
