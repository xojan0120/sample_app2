require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

  test "account_activation" do
    user = users(:michael)
    user.activation_token = User.new_token
    mail = UserMailer.account_activation(user)
    assert_equal "Account activation", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["noreply@example.com"], mail.from
    assert_match user.name,               mail.body.encoded
    assert_match user.activation_token,   mail.body.encoded
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
