require 'rails_helper'

RSpec.describe User, type: :model do
  it do
    pp FactoryBot.create(:user, :not_admin)
  end

  it "メールアドレスを全て小文字にする" do
    test_address = "John_Smith@Example.com"
    user = FactoryBot.create(:user, email: test_address)
    expect(user.email).to eq test_address.downcase
  end
end
