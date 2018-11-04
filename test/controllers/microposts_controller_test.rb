require 'test_helper'

class MicropostsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @micropost = microposts(:orange)
  end

  # ログインしていないとき、createはリダイレクトされるべき
  test "should redirect create when not logged in" do
    # Micropostsコントローラのcreateアクションを実行してMicropostの件数が変化するか
    # microposts POST   /microposts(.:format)                   microposts#create
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "Lorem ipsum" } }
    end

    # login_urlへリダイレクトされたかどうか
    # login GET    /login(.:format)                        sessions#new
    assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in" do
    # Micropostsコントローラのdeleteアクションを実行してMicropostの件数が変化するか
    # micropost DELETE /microposts/:id(.:format)               microposts#destroy
    assert_no_difference 'Micropost.count' do
      delete micropost_path(@micropost)
    end

    # login_urlへリダイレクトされたかどうか
    # login GET    /login(.:format)                        sessions#new
    assert_redirected_to login_url
  end

  test "should redirect destroy for wrong micropost" do
    # テストユーザでログインする
    # test/test_helper.rbに定義有り。(ActionDispatch::IntegrationTestクラスで定義されているほう)
    # あらかじめデフォルトオプションでパスワードと、remember_meを1にしてPOSTしている
    log_in_as(users(:michael))

    # test/fixtures/microposts.ymlからマイクロポストのmichaelが投稿者ではないテストデータ取得
    micropost = microposts(:ants)

    # delete後、Micropostの件数が変化していないことをテスト
    assert_no_difference 'Micropost.count' do
      delete micropost_path(micropost)
    end

    # root_urlへリダイレクトされているか
    # root GET    /                                       static_pages#home
    assert_redirected_to root_url
  end

end
