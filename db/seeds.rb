# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create!(name: "Example User",
             email: "example@railstutorial.org",
             password: "foobar",
             password_confirmation: "foobar",
             admin: true,
             activated: true,
             activated_at: Time.zone.now,
             unique_name: "example_user"
            )

99.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"

  # 半角スペースとドットをアンダースコアに変換＆小文字変換
  unique_name = name.gsub(/ /,"_").gsub(".","_").downcase
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now,
               unique_name: unique_name
              )
end

# ユーザーテーブルから作成日時順で6人のUserオブジェクトを配列で取得する
users = User.order(:created_at).take(6)

50.times do
  content = Faker::Lorem.sentence(5)
  users.each { |user| user.microposts.create!(content: content) }
end

# リレーションシップ
users = User.all
user = users.first # 最初のユーザ
following = users[2..50] # usersの3番目～51番目を、最初のユーザにフォローされる人たちとして取得
followers = users[3..40] # usersの4番目～41番目を、最初のユーザをフォローする人たちとして取得
following.each { |followed| user.follow(followed) } # 最初のユーザがfollowingの人たちをフォローする
followers.each { |follower| follower.follow(user) } # followersの人たちが最初のユーザをフォローする
