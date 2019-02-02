require 'rails_helper'

RSpec.describe DirectMessageStat, type: :model do
  it "userとdirect_messageがあれば有効な状態であること" do
    user = FactoryBot.create(:user)
    dm = FactoryBot.create(:direct_message)
    dm_stat = DirectMessageStat.new(user: user, direct_message: dm)
    expect(dm_stat).to be_valid
  end

  it "userがなければ無効な状態であること" do
    dm = FactoryBot.create(:direct_message)
    dm_stat = DirectMessageStat.new(direct_message: dm)
    expect(dm_stat).to be_invalid
  end

  it "direct_messageがなければ無効な状態であること" do
    user = FactoryBot.create(:user)
    dm_stat = DirectMessageStat.new(user: user)
    expect(dm_stat).to be_invalid
  end
end
