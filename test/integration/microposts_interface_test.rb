require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "micropost interface" do
    # テストユーザでログインする
    # test/test_helper.rbに定義有り。(ActionDispatch::IntegrationTestクラスで定義されているほう)
    # あらかじめデフォルトオプションでパスワードと、remember_meを1にしてPOSTしている
    log_in_as(@user)

    # root GET    /                                       static_pages#home
    get root_path

    # will_paginateがあるか
    assert_select 'div.pagination'

    # ファイルアップロードフォームが表示されているか
    assert_select 'input[type=file]'

    # 無効な空本文で送信
    # マイクロポストの数が変化していないか
    assert_no_difference 'Micropost.count' do
      # microposts POST   /microposts(.:format)                   microposts#create
      post microposts_path, params: { micropost: { content: "" } }
    end

    # エラーメッセージが表示されているか
    assert_select 'div#error_explanation'

    # 有効な本文で送信
    # ↓でFaker使ってもよさそうだけど・・・ content = Faker::Lorem.sentence
    content = "This micropost really ties the room together"

    # fixtureで定義されたファイルをアップロード
    picture = fixture_file_upload('test/fixtures/rails.png', 'image/png')

    # マイクロポストの数が+1されているか
    assert_difference 'Micropost.count', 1 do
      # microposts POST   /microposts(.:format)                   microposts#create
      post microposts_path, params: { micropost: { content: content,
                                                   picture: picture } }
    end

    # assignsメソッドで、投稿に成功したあとのmicroposts#createアクション内の
    # micropostにアクセスできるようにしている。
    # 投稿したマイクロポストに画像はあるか？
    assert assigns(:micropost).picture?

    # root_urlへリダイレクトされたか
    # root GET    /                                       static_pages#home
    assert_redirected_to root_url

    # 実際にリダイレクト先へ移動する
    follow_redirect!

    # responce.bodyに先程投稿したマイクロポストがあるかどうか
    assert_match content, response.body

    # 投稿を削除する
    # deleteリンクがあるかどうか
    assert_select 'a', text: 'delete'

    # @userのマイクロポストの1ページ目(created_atの降順で最初の30件)の1件目取得
    first_micropost = @user.microposts.paginate(page: 1).first

    # マイクロポストの数が-1されているか
    assert_difference 'Micropost.count', -1 do
      # micropost DELETE /microposts/:id(.:format)               microposts#destroy
      delete micropost_path(first_micropost)
    end

    # 違うユーザーのプロフィールにアクセス（削除リンクがないことを確認)
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count: 0
  end

  test "micropost sidebar count" do
    # テストユーザでログインする
    # test/test_helper.rbに定義有り。(ActionDispatch::IntegrationTestクラスで定義されているほう)
    # あらかじめデフォルトオプションでパスワードと、remember_meを1にしてPOSTしている
    log_in_as(@user)

    # root GET    /                                       static_pages#home
    get root_path

    assert_match "#{@user.microposts.count} microposts", response.body

    # まだマイクロポストを投稿していないユーザー
    other_user = users(:malory)

    # 別のテストユーザでログインする
    # test/test_helper.rbに定義有り。(ActionDispatch::IntegrationTestクラスで定義されているほう)
    # あらかじめデフォルトオプションでパスワードと、remember_meを1にしてPOSTしている
    log_in_as(other_user)

    # root GET    /                                       static_pages#home
    get root_path

    # 本文に0 micropostsが含まれているかどうか
    assert_match "0 microposts", response.body

    # 別のテストユーザでマクロポストを投稿
    other_user.microposts.create!(content: "A micropost")
    # root GET    /                                       static_pages#home
    get root_path
    # 本文に1 micropostが含まれているかどうか
    assert_match "1 micropost", response.body

  end

  test "@返信すると、自分のフィードと相手のフィードだけにその投稿が表示されているか" do
    # テストユーザ取得
    #   michael (返信元ユーザ)
    #   archer  (返信先ユーザ)
    #   lana    (その他ユーザ1(返信元をフォローしている))
    #   john    (その他ユーザ2(返信元ユーザをフォローしていない)
    from_user   = users(:michael)
    to_user     = users(:archer)
    other_user1 = users(:lana)
    other_user2 = users(:john)

    # 返信先ユーザのunique_name取得
    unique_name = to_user.unique_name

    # @返信の内容
    content = "@#{unique_name} 結合テストで返信テスト"

    # 返信元ユーザでログイン
    log_in_as(from_user)

    # @返信を投稿
    post microposts_path, params: { micropost: { content: content } }

    # 投稿のid取得
    micropost_id = from_user.microposts.first.id

    # 返信元ユーザのフィードに@返信の投稿があるか
    get root_path
    assert_select "#micropost-#{micropost_id} span.content", text: content

    # 返信先ユーザのフィードに@返信の投稿があるか
    log_in_as(to_user)
    get root_path
    assert_select "#micropost-#{micropost_id} span.content", text: content

    # その他ユーザ1のフィードに@返信の投稿があるか
    log_in_as(other_user1)
    get root_path
    assert_select "#micropost-#{micropost_id} span.content", text: content

    # その他のユーザ2のフィードに@返信の投稿がないか
    log_in_as(other_user2)
    get root_path
    assert_no_match "micropost-#{micropost_id}", response.body
  end

end
