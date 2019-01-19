FactoryBot.define do
  factory :reply do
    #reply_to 1
    association :micropost
  end
end
