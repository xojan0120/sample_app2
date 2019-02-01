require 'rails_helper'

RSpec.describe DirectMessage, type: :model do

  it "有効なファクトリを持つこと" do
    dm = FactoryBot.create(:direct_message, :with_sender_receiver)
    expect(dm).to be_valid
  end

  # バリデーションテスト
  it { is_expected.to validate_presence_of :sender_id }
  it { is_expected.to validate_presence_of :receiver_id }

  # boolean型のバリデーションについては、バリデーション対象のカラムにセットされるときに
  # ActiveRecordが何でもboolean型にしてしまうため、意味がないため削除。
  # https://qiita.com/YumaInaura/items/b26fdfee8affd4cb77ef
  #it { is_expected.to validate_inclusion_of(:sender_display).in_array([true, false]) }
  #it { is_expected.to validate_inclusion_of(:receiver_display).in_array([true, false]) }

  it "2人のユーザのメッセージが取得できる" do
    user1 = FactoryBot.create(:user)
    user2 = FactoryBot.create(:user)
    pair_user_id = [user1.id, user2.id]

    user1.send_dm("my name is #{user1.name}", user2)
    user2.send_dm("my name is #{user2.name}", user1)
    dms = [user1.sent_direct_messages.first, user2.sent_direct_messages.first]

    expect(DirectMessage.get_dm(pair_user_id)).to match_array(dms)
  end

end
