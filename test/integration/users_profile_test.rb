require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:michael)
  end

  test "profile display" do
    # ユーザのプロフィールページをGET
    # user GET    /users/:id(.:format)                    users#show
    # /users/1
    get user_path(@user)

    # Usersビューのshow.html.erbテンプレートが表示されたか
    assert_template 'users/show'

    # titleタグに full_title(@user.name) があるか
    # full_title(@user.name) => "#{@user.name} | Ruby on Rails Tutorial Sample App"
    assert_select 'title', full_title(@user.name)

    # h1タグに @user.name があるか
    assert_select 'h1', text: @user.name

    # h1タグ配下にimg.gravatarがあるか
    # h1>img.gravatarはh1の配下にimg.gravatarがあるか。
    # h1 img.gravatarでも同じっぽい？
    assert_select 'h1>img.gravatar'

    # @userのマイクロポストの件数の文字列が、本文に含まれているか
    assert_match @user.microposts.count.to_s, response.body

    # div.paginationがあるか
    assert_select 'div.pagination'

    # @userのマイクロポストの1ページ目分(作成日時の降順の最初の30件)の
    # contentが本文にそれぞれあるか
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end

    # will_paginateが1度のみ表示されているか
    assert_select 'div.pagination', count: 1

    # フォロー数の統計情報が表示されているか
    assert_select "strong#following" , { text: @user.following.count.to_s  }

    # フォロワー数の統計情報が表示されているか
    assert_select "strong#followers" , { text: @user.followers.count.to_s  }
  end
end
