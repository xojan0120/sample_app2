require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest
  
  def setup
    # test/fixtures/users.ymlから取得
    @user  = users(:michael)
    @other = users(:archer)

    # test/test_helper.rb
    # テストユーザーとしてログインする
    log_in_as(@user)
  end

  test "following page" do
    # @userがフォローしている人たちの一覧ページをGET
    # following_user GET    /users/:id/following(.:format)          users#following
    get following_user_path(@user)

    # @userがフォローしている人は空ではないか？
    assert_not @user.following.empty?

    # 本文中に、@userがフォローしている人数(文字列)はあるか
    assert_match @user.following.count.to_s, response.body

    # @userがフォローしている人たちそれぞれについての
    # ユーザーページへのリンクはあるか
    @user.following.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "followers page" do
    # @userをフォローしている人たちの一覧ページをGET
    # followers_user GET    /users/:id/followers(.:format)          users#followers
    get followers_user_path(@user)

    # @userをフォローしている人は空ではないか？
    assert_not @user.followers.empty?

    # 本文中に、@userをフォローしている人数(文字列)はあるか
    assert_match @user.followers.count.to_s, response.body

    # @userをフォローしている人たちそれぞれについての
    # ユーザーページへのリンクはあるか
    @user.followers.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "should follow a user the standard way" do
    # @userが@otherをフォローすることで@userのフォロー数が+1されるか
    assert_difference '@user.following.count', 1 do
      # relationships POST   /relationships(.:format)                relationships#create
      post relationships_path, params: { followed_id: @other.id }
    end
  end

  test "should follow a user with Ajax" do
    # @userが@otherをフォローすることで@userのフォロー数が+1されるか
    assert_difference '@user.following.count', 1 do
      # relationships POST   /relationships(.:format)                relationships#create
      # xhr: trueにすることでAjaxでリクエストを発行する
      post relationships_path, xhr: true, params: { followed_id: @other.id }
    end
  end

  test "should unfollow a user the standard way" do
    # @userが@otherをフォローする
    @user.follow(@other)

    # ？？？ 
    relationship = @user.active_relationships.find_by(followed_id: @other.id)

    # @userが@otherをアンフォローすることで@userのフォロー数が-1されるか
    assert_difference '@user.following.count', -1 do
      # relationship DELETE /relationships/:id(.:format)            relationships#destroy
      delete relationship_path(relationship)
    end
  end

  test "should unfollow a user with Ajax" do
    # @userが@otherをフォローする
    @user.follow(@other)

    # ？？？ 
    relationship = @user.active_relationships.find_by(followed_id: @other.id)

    # @userが@otherをアンフォローすることで@userのフォロー数が-1されるか
    assert_difference '@user.following.count', -1 do
      # relationship DELETE /relationships/:id(.:format)            relationships#destroy
      # xhr: trueにすることでAjaxでリクエストを発行する
      delete relationship_path(relationship), xhr: true
    end
  end

  test "feed on Home page" do
    # root GET    /                                       static_pages#home
    get root_path

    @user.feed.paginate(page: 1).each do |micropost|
      assert_match CGI.escapeHTML(micropost.content), response.body
      if micropost.content =~ /sorry/
        fo = open("aaa.txt","w")
        fo.print response.body
        fo.close
      end
      #assert_match (micropost.content), response.body
    end
  end
end
