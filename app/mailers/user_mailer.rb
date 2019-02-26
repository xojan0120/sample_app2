class UserMailer < ApplicationMailer

  # 引数のuser宛にアカウント有効化メールを送信する
  def account_activation(user)
    @user = user
    mail to: user.email, subject: "Account activation"
  end

  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Password reset"
  end

  def follower_notification(follow_user, followed_user)
    @follow_user   = follow_user
    @followed_user = followed_user
    mail to: followed_user.email, subject: "Followed Notification"
  end
end
