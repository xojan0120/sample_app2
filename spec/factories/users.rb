FactoryBot.define do
  factory :user do
    name "John Smith"
    email "john_smith@example.com"
    password_digest User.digest('password')
    unique_name "john_smithx"
  end
end
