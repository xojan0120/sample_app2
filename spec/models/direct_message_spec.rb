require 'rails_helper'

RSpec.describe DirectMessage, type: :model do

  it "有効なファクトリを持つこと" do
    dm = FactoryBot.create(:direct_message)
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


  #it "test" do
  #  sender = FactoryBot.create(:user)
  #  receiver = FactoryBot.create(:user)
  #  dm = FactoryBot.build(:direct_message, sender_id: sender.id, receiver_id: receiver.id, sender_display: false)
  #  expect(dm).to be_valid
  #end

end
