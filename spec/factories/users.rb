FactoryBot.define do
  factory :user do
    name                "user1"
    email               "user1@gmail.com"
    password_digest     User.digest('foobar')
    admin               true
    activated           true
    activated_at        Time.now
    unique_name         "user1"
  end

  trait :not_admin do
    admin false
  end
end
