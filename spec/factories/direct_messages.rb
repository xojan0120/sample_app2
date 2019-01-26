FactoryBot.define do
  factory :direct_message do
    sequence(:content) { |n| "message#{n}" }
    sender_id nil
    receiver_id nil
    sender_display true
    receiver_display true
    picture nil

    before(:create) do |direct_message|
      user1 = FactoryBot.create(:user)
      user2 = FactoryBot.create(:user)
      direct_message.sender_id = user1.id
      direct_message.receiver_id = user2.id
    end

  end
end
