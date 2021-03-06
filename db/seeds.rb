# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

1.upto 3 do |i|
  User.create!(name: "user#{i}",
               email: "user#{i}@gmail.com",
               password: "foobar",
               password_confirmation: "foobar",
               admin: true,
               activated: true,
               activated_at: Time.zone.now,
               unique_name: "uniq_user#{i}"
              )
end

user_kido = User.create!(name: "木戸涼介",
             email: "user4@gmail.com",
             password: "foobar",
             password_confirmation: "foobar",
             activated: true,
             activated_at: Time.zone.now,
             unique_name: "kido_ryosuke"
            )

99.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"

  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now,
               unique_name: "example_#{n+1}"
              )
end

# フォロワー通知設定
User.all.each do |user|
  user.create_follower_notification(enabled: false)
end

# ユーザーテーブルから作成日時順で6人のUserオブジェクトを配列で取得する
users = User.order(:created_at).take(6)
50.times do
  content = Faker::Lorem.sentence(5)
  users.each { |user| user.microposts.create!(content: content) }
end

# リレーションシップ
following = User.all[1..50] # User.allの2番目～51番目を、最初のユーザにフォローされる人たちとして取得
followers = User.all[3..40] # user.allの4番目～41番目を、最初のユーザをフォローする人たちとして取得
following.each { |followed| User.first.follow(followed) } # 最初のユーザがfollowingの人たちをフォローする
followers.each { |follower| follower.follow(User.first) } # followersの人たちが最初のユーザをフォローする
following.each { |followed| user_kido.follow(followed) }

# 画像テスト用
picture = Rack::Test::UploadedFile.new(Rails.root.join('spec/factories/images/rails.png'))
Micropost.create!(content:"test",picture: picture, user: user_kido, created_at: Time.now)

