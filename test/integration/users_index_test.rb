require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @admin = users(:michael)
    @non_admin = users(:archer)
  end

  test "index including pagination" do
    # log_in_asはtest/test_helper.rbのclass ActionDispatch::IntegrationTestにあり
    log_in_as(@user)

    # users GET    /users(.:format)                        users#index
    get users_path

    # users/indexビューが表示されたか
    assert_template 'users/index'

    # div.paginationタグがあるか
    assert_select 'div.pagination', count: 2

    # Userの1ページ目の各ユーザについて、user_pathへのリンク(テキストはユーザ名)があるか
    User.paginate(page: 1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end

  # 管理者を含むページネーションと削除リンクテスト
  test "index as admin including pagination and delete links" do
    # log_in_asはtest/test_helper.rbのclass ActionDispatch::IntegrationTestにあり
    log_in_as(@admin)

    # users GET /users(.:format) users#index
    get users_path

    # users/indexビューが表示されたか
    assert_template 'users/index'

    # ページネーションが2つあるか
    assert_select 'div.pagination', count: 2

    # 1ページ目のユーザ取得
    first_page_of_users = User.paginate(page: 1)

    # ユーザ毎にユーザ名のリンクと、削除リンク（管理者のみ）があるか
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end

    # @non_adminのユーザを削除してユーザ数が1減るか
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  # 非管理者のインデックス表示テスト
  test "index as non-admin" do
    # log_in_asはtest/test_helper.rbのclass ActionDispatch::IntegrationTestにあり
    log_in_as(@non_admin)

    # users GET /users(.:format) users#index
    get users_path

    # 削除リンクは0か
    assert_select 'a', text: 'delete', count: 0
  end
end
