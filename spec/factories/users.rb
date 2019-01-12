FactoryBot.define do
  factory :user do
    sequence(:name)        {|n| "user#{n}"}
    sequence(:email)       {|n| "user#{n}@gmail.com"}
    password_digest             User.digest('foobar')
    admin                       true
    activated                   true
    activated_at                Time.now
    sequence(:unique_name) {|n| "user#{n}"}
  end

  trait :not_admin do
    admin false
  end
end
