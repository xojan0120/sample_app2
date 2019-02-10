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

  # to_user_num の人数分のDM送信済み
  # DMのcreated_atは最後に送ったものが一番新しくなる
  # 下記トレイトを用意したが、送り先のユーザを取得しにくいなどの理由で
  # 使いにくいので没
  #trait :with_sent do
  #  transient do
  #    to_user_num 1
  #  end

  #  after(:create) {|fr_user ,evaluator|
  #    to_users = create_list(:user, evaluator.to_user_num).sort
  #    t = Time.now
  #    to_users.each do |to_user|
  #      room = Room.make([fr_user, to_user])
  #      dm = fr_user.send_dm(room, "hello, #{to_user.name}")
  #      dm.update_attribute(:created_at, t += 1)
  #    end
  #  }
  #end
end
