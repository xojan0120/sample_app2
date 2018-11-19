require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do # post後、User.countの値が変わらないことを期待している(下記のparamsで無効なデータで登録しようとしているため)
      post signup_path, params: { user: { name: "",
                                         email: "user@invalid",
                                         password: "foo",
                                         password_confirmation: "bar",
                                         unique_name: ""
      } }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.alert'
    assert_select 'form[action="/signup"]'
  end

  test "valid signup information with account activation" do

    # /signupをGETし、users#newアクションを実行
    get signup_path

    # /usersへparamsでPOSTし、users#createアクションを実行。
    # POST後、User.countの値が+1される。
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: "Example User",
                                         email: "user@example.com",
                                         password: "password",
                                         password_confirmation: "password",
                                         unique_name: "example_user"
      } }
    end

    # 配信されたメッセージが１つである。
    assert_equal 1, ActionMailer::Base.deliveries.size

    # Usersコントローラのcreateアクションのインスタンス変数にアクセスして取得している
    # どのコントローラのどのアクションのインスタンス変数にアクセスされるかは、おそらく、
    # 直近のルーティング実行時のアクション。ここだと、post users_path。これで実行される
    # アクションをrails routesで確認すると、users#create。よってuser#createアクション内の
    # @userというインスタンス変数にアクセスしている。
    user = assigns(:user)

    # userは有効化されていない
    assert_not user.activated?

    # 有効化していない状態でログインしてみる
    log_in_as(user)
    # userはログインしていない
    assert_not is_logged_in?

    # 有効化トークンが不正な場合
    get edit_account_activation_path("invalid token", email: user.email)
    # userはログインしていない
    assert_not is_logged_in?

    # トークンは正しいがメールアドレスが無効な場合
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    # userはログインしていない
    assert_not is_logged_in?

    # 有効化トークンが正しい場合(account_activations#editが実行され、users#showへリダイレクトされる)
    # edit_account_activation GET => /account_activations/:id/edit(.:format) => account_activations#edit
    # :idにuser.activation_token、(.:format)に?email=#{user.email}がセットされる
    get edit_account_activation_path(user.activation_token, email: user.email)
    # userをデータベースから読み込み直すと、有効化されている
    assert user.reload.activated?

    # リダイレクトを実行する
    follow_redirect!

    # users/showアクションのテンプレートが表示される
    assert_template 'users/show'

    # userはログインしている
    assert is_logged_in?
  end
end
