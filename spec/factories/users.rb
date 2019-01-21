FactoryBot.define do
  factory :user do
    sequence(:name)        {|n| "user#{n}"}
    sequence(:email)       {|n| "user#{n}@gmail.com"}
    password_digest             User.digest('foobar')
    admin                       true
    activated                   true
    activated_at                Time.now
    sequence(:unique_name) {|n| "user#{n}"}

    transient do
      followed_number 1  # デフォルトフォロー人数
      follower_number 1  # デフォルトフォロワー人数
    end
  end

  trait :not_admin do
    admin false
  end

  trait :with_microposts do
    after(:create) {|user|
      create_list(:micropost, 2, user:user)
    }
  end

  # フォローユーザ付き
  trait :with_following do
    after(:create) {|user,evaluator|
      user.following << create_list(:user, evaluator.followed_number)
    }
  end

  # フォロワーユーザ付き
  trait :with_followers do
    after(:create) {|user,evaluator|
      user.followers << create_list(:user, evaluator.follower_number)
    }
  end
end
