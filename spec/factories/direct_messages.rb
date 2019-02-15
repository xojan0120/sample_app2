FactoryBot.define do
  factory :direct_message do
    sequence(:content) { |n| "message#{n}" }
    picture nil
    user
    room
  end
end
