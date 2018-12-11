require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "unsuccessful edit" do
    # ログインする(log_in_asはtest/test_helper.rbで定義)
    log_in_as(@user)

    # edit_user GET    /users/:id/edit(.:format)               users#edit
    get edit_user_path(@user)

    # users/editビューが表示されたか
    assert_template 'users/edit'

    # 無効な編集情報を送信
    patch user_path(@user), params: { user: { name: "",
                                              email: "foo@invalid",
                                              password: "foo",
                                              password_confirmation: "bar" } }

    # エラーメッセージが表示されているか
    assert_select "div.alert", "The form contains 4 errors" 
  end

  test "successful edit with fiendly forwarding" do
    # edit_user GET    /users/:id/edit(.:format)               users#edit
    get edit_user_path(@user)

    # session[:forwarding_url](ユーザが開こうとしていたURL) 
    assert_equal session[:forwarding_url], edit_user_url(@user)

    # ログインする(log_in_asはtest/test_helper.rbのclass ActionDispatch::IntegrationTest内で定義)
    log_in_as(@user)

    # log_in_asによってlogin_pathにPOSTされる(POST /login(.:format) sessions#create)ので、
    # そこでredirect_back_orメソッドが実行され、session.delete(:forwarding_url)される
    assert_nil session[:forwarding_url]

    #
    assert_redirected_to edit_user_url(@user)


    # edit箇所はnameとemailのみ。パスワードは変更しないのでブランク
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name: name,
                                              email: email, 
                                              password: "",
                                              password_confirmation: "" } }

    # flashメッセージは空ではないか(編集成功メッセージが入るはず)
    assert_not flash.empty?

    # @userのプロフィールページへリダイレクトされるかどうか
    assert_redirected_to @user


    # @userの読込直し。ここでは、上記のpatchで更新したuserの
    # 内容を読込なおしている。
    @user.reload

    # nameの変更がされているか
    assert_equal name,  @user.name

    # emailの変更がされているか
    assert_equal email, @user.email
  end
end
