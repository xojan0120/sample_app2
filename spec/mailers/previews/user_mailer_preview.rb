# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/account_activation
  def account_activation
    # テスト用にデータベースの最初のユーザーを取得
    user = User.first

    # ユーザーの有効化トークン属性に、新しいトークンを設定
    user.activation_token = User.new_token

    # Userメーラーでuser宛にアカウント有効化メールを送信する
    UserMailer.account_activation(user)
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/password_reset
  def password_reset
    # テスト用にデータベースの最初のユーザーを取得
    user = User.first

    # ユーザーの再設定トークン属性に、新しいトークンを設定
    user.reset_token = User.new_token

    # Userメーラーでuser宛にパスワード再設定メールを送信する
    UserMailer.password_reset(user)
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/follower_notification
  def follower_notification
    follow_user   = User.first
    followed_user = User.second

    UserMailer.follower_notification(follow_user, followed_user)
  end
end
