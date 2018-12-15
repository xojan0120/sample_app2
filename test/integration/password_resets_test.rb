require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

  def setup
    # メールの送信キューをクリアする
    # config/environments/development.rbの
    # config.action_mailer.delivery_method = :test 
    # に設定すると、メールは実際に送信されず、送信キューにメールがたまる。(このキューにはActionMailer::Base.deliveriesというメソッドでアクセスできる)
    # 送信キューはclearメソッドで明示的にクリアしないと消えないので、ここでクリアしている。
    ActionMailer::Base.deliveries.clear
    @user = users(:michael) # test/fixtures/users.ymlで定義されたテスト用データ内のmichaelデータを取得している
  end

  test "password resets" do
    # パスワード再設定用ページをGET
    # new_password_reset GET    /password_resets/new(.:format)          password_resets#new
    get new_password_reset_path

    # パスワード再設定用ページが表示されたか
    assert_template 'password_resets/new'

    ##########################################################################################
    # 無効なメールアドレスのテスト
    ##########################################################################################
    # パスワード再設定用ページで空メールアドレスでPOST
    # password_resets POST   /password_resets(.:format)              password_resets#create
    post password_resets_path, params: { password_reset: { email: "" } }

    # 一時メッセージは空ではないことをテスト(一時エラーメッセージは表示されているかどうか)
    assert_not flash.empty?

    # パスワード再設定用ページが再び表示されたか
    assert_template 'password_resets/new'

    ##########################################################################################
    # 有効なメールアドレスのテスト
    ##########################################################################################
    # パスワード再設定用ページで有効メールアドレスでPOST
    # password_resets POST   /password_resets(.:format)              password_resets#create
    post password_resets_path, params: { password_reset: { email: @user.email } }

    # 期待値："@userの再設定用ダイジェスト", 実際値："@userを再読込した後の再設定用ダイジェスト"    が一致しない
    # 上記のpostで、@userに対して再設定用トークンが作成され、データベース上の@userの再設定用ダイジェスト(@user.reset_digest)が更新される
    # この更新後の再設定用ダイジェストが@user.reload.reset_digestである。
    # 更新前の再設定用ダイジェストは@user.reset_digestになる。
    # つまり、期待値と実際値がここで異なっていることをテストしている。
    assert_not_equal @user.reset_digest, @user.reload.reset_digest

    # 期待値：1、実際値：送信済みキューのサイズ
    # つまりメールが1通送信されたことをテストしている
    assert_equal 1, ActionMailer::Base.deliveries.size

    # 一時メッセージが空ではないことをテスト(一時メッセージにメール送信完了メッセージが入るはずのため)
    assert_not flash.empty?

    # root_urlへリダイレクトされたか
    # root GET    /                                       static_pages#home
    assert_redirected_to root_url

    ##########################################################################################
    # パスワード再設定フォームのテスト
    ##########################################################################################
    # assignsメソッドを使用すると対応するアクション内あるインスタンス変数へアクセスできる。
    # ここでいう対応するアクションとは、直前のアクション、つまり password_resets#create内で
    # 定義されている@user変数
    user = assigns(:user)

    # 再設定トークン有り、無効なメールアドレス(空メールアドレス)で、再設定用URLへアクセスしてきた場合(空メールアドレスのURLってありえるのか？)のテスト
    # edit_password_reset_path、つまり、パスワード再設定用メールに記載されている再設定用URLをGETしている
    # edit_password_reset GET    /password_resets/:id/edit(.:format)     password_resets#edit
    # edit_password_reset_path(user.reset_token, email:"")
    # /password_reset/#{user.reset_token}/edit?email=空メールアドレス
    get edit_password_reset_path(user.reset_token, email:"")

    # root_urlへリダイレクトされたか
    # root GET    /                                       static_pages#home
    assert_redirected_to root_url

    # userの有効属性を無効にしている(activated:true -> falseに変更(fixturesのmichaelは最初からactivated:trueにしてある))
    user.toggle!(:activated)

    # 無効なユーザ状態で、再設定トークン有り、有効なメールアドレスで再設定用URLへアクセスしてきた場合のテスト
    # edit_password_reset_path、つまり、パスワード再設定用メールに記載されている再設定用URLをGETしている
    # edit_password_reset GET    /password_resets/:id/edit(.:format)     password_resets#edit
    # edit_password_reset_path(user.reset_token, email:"")
    # → /password_reset/#{user.reset_token}/edit?email=#{user.email}
    get edit_password_reset_path(user.reset_token, email:user.email)

    # root_urlへリダイレクトされたか
    # root GET    /                                       static_pages#home
    assert_redirected_to root_url

    # userの有効属性を有効に戻している
    user.toggle!(:activated)

    # 有効なユーザ状態で、メールアドレスが有効で、トークンが無効
    get edit_password_reset_path('wrong token', email:user.email)

    # root_urlへリダイレクトされたか
    # root GET    /                                       static_pages#home
    assert_redirected_to root_url

    # 有効なユーザ状態で、メールアドレスもトークンも有効
    get edit_password_reset_path(user.reset_token, email:user.email)

    # パスワード再設定用ページ(パスワード変更ページ)が表示されたか
    assert_template 'password_resets/edit'

    # パスワード再設定用ページ(パスワード変更ページ)内に、
    # 再設定対象のユーザーのメールアドレスが隠しフィールドで埋め込まれているかどうか
    # 隠しフィールドでメールアドレスを埋め込んで置く理由は、後続のpassword_resets#updateアクション内で
    # ユーザーのpassword_digest属性を更新するために必要なキーとして、メールアドレスを渡すため。
    assert_select "input[name=email][type=hidden][value=?]", user.email

    # パスワード再設定用ページに、無効なパスワードを入力したものをpatch
    # patchはブラウザ側でサポートされていないので、railsがpostメソッド+hiddenフィールドでpatchを
    # 擬似的に実現している。
    # password_reset PATCH  /password_resets/:id(.:format)          password_resets#update
    # → /password_resets/#{user.reset_token}
    patch password_reset_path(user.reset_token), params: { email: user.email,
                                                           user: { password:              "foobaz",
                                                                   password_confirmation: "barquux" } }

    # エラーメッセージが表示されたか
    assert_select 'div#error_explanation'

    # パスワード再設定用ページに、空パスワードを入力したものをpatch
    # password_reset PATCH  /password_resets/:id(.:format)          password_resets#update
    # → /password_resets/#{user.reset_token}
    patch password_reset_path(user.reset_token), params: { email: user.email,
                                                           user: { password:              "",
                                                                   password_confirmation: "" } }

    # エラーメッセージが表示されたか
    assert_select 'div#error_explanation'

    # 有効なパスワードとパスワード確認
    # パスワード再設定用ページに、有効なパスワードを入力したものをpatch
    # password_reset PATCH  /password_resets/:id(.:format)          password_resets#update
    # → /password_resets/#{user.reset_token}
    patch password_reset_path(user.reset_token), params: { email: user.email,
                                                           user: { password:              "foobaz",
                                                                   password_confirmation: "foobaz" } }
    
    # パスワード再設定後、userのreset_digestがnilになっているか
    assert_nil user.reload.reset_digest

    # テストユーザがログインしている
    assert is_logged_in?

    # 一時メッセージが空ではない(成功のメッセージが表示される)
    assert_not flash.empty?

    # ユーザーページ(users#/show)へリダイレクトされる 
    # user GET    /users/:id(.:format)                    users#show
    # → /users/#{user.id}
    assert_redirected_to user

  end

  test "expired token" do

    # パスワード再設定用ページをGET
    # new_password_reset GET    /password_resets/new(.:format)          password_resets#new
    get new_password_reset_path

    # パスワード再設定用ページでメールアドレスをPOST
    # password_resets POST   /password_resets(.:format)              password_resets#create
    post password_resets_path, params: { password_reset: { email: @user.email } }

    # assignsメソッドを使用すると対応するアクション内あるインスタンス変数へアクセスできる。
    # ここでいう対応するアクションとは、直前のアクション、つまり password_resets#create内で
    # 定義されている@user変数
    @user = assigns(:user)

    # @userの再設定URL送信時刻を3時間前に変更
    # app/models/user.rb の password_reset_expired?で
    # パスワード再設定メール送信時刻が2時間以上前の場合に
    # 期限切れと定義しているので、下記で期限切れにしている
    @user.update_attribute(:reset_sent_at, 3.hours.ago)

    # 有効なメールアドレスとパスワードでpatch(POST + hiddenフィールドで擬似PATCH)
    # password_reset PATCH  /password_resets/:id(.:format)          password_resets#update
    # → /password_resets/#{@user.reset_token}
    patch password_reset_path(@user.reset_token), params: { email: @user.email,
                                                            user: { password: "foobar",
                                                                    password_confirmation: "foobar" } }

    # 上記patchにより、password_resets#updateアクションを実行しようとするが、
    # PasswordResetsControllerのbefore_action :check_expirationメソッドがupdateアクションの
    # 前に実行され、このメソッドによりパスワード再設定メール送信時刻が2時間以上前かどうかが
    # チェックされ、ここでは3時間前に設定されているので、new_password_reset_url(パスワード再設定用ページ)へ
    # リダイレクトされる

    # レスポンスがリダイレクトコード(300～399)である
    assert_response :redirect

    # リダイレクト先に実際に移動する
    follow_redirect!

    # レスポンス本文にexpiredという期限切れを表す英単語があるかチェック
    # /i で大文字小文字無視
    assert_match /expired/i, response.body

  end

end
