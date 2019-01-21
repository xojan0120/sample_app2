FactoryBot.define do
  factory :micropost do
    sequence(:content) {|n| "test message#{n}"}
    association :user

    transient do
      reply_to nil
    end
  end

  trait :with_picture do
    #picture { Rack::Test::UploadedFile.new(Rails.root.join('spec/factories/images/rails.png')) }
    picture { 
      Rack::Test::UploadedFile.new(
        Rails.root.join(Settings.test_image_path.rails_log)
      )
    }
  end

  trait :with_reply do
    after(:create) {|micropost, evaluator|
      micropost.replies.create(reply_to: evaluator.reply_to)
    }
  end
end
