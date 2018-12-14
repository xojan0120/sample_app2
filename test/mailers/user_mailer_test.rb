require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

  test "account_activation" do
    user = users(:michael)

    # ユーザーの有効化トークン属性に、新しいトークンを設定
    user.activation_token = User.new_token

    # Userメーラーでuser宛にアカウント有効化メールを送信する
    mail = UserMailer.account_activation(user)

    # サブジェクトはAccount actionvationか
    assert_equal "Account activation", mail.subject

    # 宛先はuser.emailか。 ※mail.toは配列
    assert_equal [user.email], mail.to

    # 差出人はnoreply@example.comか
    assert_equal ["noreply@example.com"], mail.from

    # 本文にuser.nameがあるか
    assert_match user.name,               mail.body.encoded

    # 本文にuser.activation_tokenがあるか
    assert_match user.activation_token,   mail.body.encoded

    # 本文にuser.emailがあるか
    assert_match CGI.escape(user.email),  mail.body.encoded
  end

  test "password_reset" do
    user = users(:michael)

    # 再設定トークンを新たに設定
    user.reset_token = User.new_token

    # 再設定メールをuser宛に送信
    mail = UserMailer.password_reset(user)

    # メールのサブジェクトは"Password reset"
    assert_equal "Password reset", mail.subject

    # メールの宛先は、user.email
    assert_equal [user.email], mail.to

    # メールの差出人は、noreply@example.com
    assert_equal ["noreply@example.com"], mail.from

    # メールの本文には、再設定トークンが含まれる
    assert_match user.reset_token,        mail.body.encoded

    # メールの本文には、メールアドレスが含まれる
    assert_match CGI.escape(user.email),  mail.body.encoded
  end

end
