require 'rails_helper'

RSpec.describe User, type: :model do
  it "メールアドレスを全て小文字にする" do
    user = FactoryBot.create(:user, name: "test", email: "John_smith@example.com")
    expect(user.email).to eq "john_smith@example.com"
  end
end
