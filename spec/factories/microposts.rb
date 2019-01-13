FactoryBot.define do
  factory :micropost do
    sequence(:content) {|n| "test message#{n}"}
    association :user
  end
end
