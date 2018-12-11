require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  # ログインせずに編集画面へアクセスしたときリダイレクトされるか
  test "should redirect edit when not logged in" do
    # edit_user GET    /users/:id/edit(.:format)               users#edit
    get edit_user_path(@user)

    # flashは空ではないか(ログインを促すメッセージが入るはず)
    assert_not flash.empty?

    # ログインURLへリダイレクトする
    assert_redirected_to login_url
  end

  # ログインせずに更新処理したときリダイレクトされるか
  test "should redirect update when not logged in" do
    # 更新処理
    patch user_path(@user), params: { user: { name: @user.name,
                                             email: @user.email } }

    # flashは空ではないか(ログインを促すメッセージが入るはず)
    assert_not flash.empty?

    # ログインURLへリダイレクトする
    assert_redirected_to login_url
  end

  # Web経由でのadmin属性変更を許可しない
  test "should not allow the admin attribute to be edited via the web" do
    # @other_userでログイン
    log_in_as(@other_user)

    # @other_userはadminではない
    assert_not @other_user.admin?

    # @other_userのadmin: trueでPATCH
    patch user_path(@other_user), params: {
                                    user: { 
                                      password:              "password",
                                      password_confirmation: "password",
                                      admin:                  true
                                    }
                                  }

    # @other_userを再読込してもadminではない
    assert_not @other_user.reload.admin?
  end

  test "should redirect edit when loggend in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when loggend in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                             email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end

  # ログインしていない状態でDELETEでログイン画面にリダイレクトされるか
  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

  # ログイン済みだが管理者でない場合にDELETEでホーム画面にリダイレクトされるか
  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end

  # ログインしていないときフォローされる側の人たちのページにアクセスした場合
  # login_urlへリダイレクトされているか
  test "should redirect following when not logged in" do
    # following_user GET    /users/:id/following(.:format)          users#following
    # => /users/#{@user.id}/following
    get following_user_path(@user)

    # login GET    /login(.:format)                        sessions#new
    assert_redirected_to login_url
  end

  # ログインしていないときフォローする側の人たちのページにアクセスした場合
  # login_urlへリダイレクトされているか
  test "should redirect followers when not logged in" do
    # followers GET    /users/:id/followers(.:format)          users#followers
    # => /users/#{@user.id}/followers
    get followers_user_path(@user)

    # login GET    /login(.:format)                        sessions#new
    assert_redirected_to login_url
  end

end
