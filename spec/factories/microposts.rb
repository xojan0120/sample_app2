FactoryBot.define do
  factory :micropost do
    sequence(:content) {|n| "test message#{n}"}
    association :user
  end

  trait :with_picture do
    picture { Rack::Test::UploadedFile.new(Rails.root.join('spec/factories/images/rails.png')) }
  end
end
