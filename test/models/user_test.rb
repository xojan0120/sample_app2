require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User",
                     email: "user@example.com",
                     password: "foobar",
                     password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "   "
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "   "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user while nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "associated microposts should be destroyed" do
    @user.save

    # @userに依存したmicropotsを作成する。
    # なお、@user.microposts.build(content: "Lorem ipsum")だとデータベースへは
    # 反映せず、Micropostオブジェクトを返してくれる
    @user.microposts.create!(content: "Lorem ipsum")
    
    # @user.destoryすることで、Micropost.countが-1になる
    assert_difference "Micropost.count", -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    # test/fixtures/users.yml から取得
    michael = users(:michael) # id = 1
    archer  = users(:archer)  # id = 2

    # michaelがarcherをフォローしていないか
    # SELECT 1 AS one FROM users INNER JOIN relationships ON users.id = relationships.followed_id
    # WHERE relationships.follower_id = 1 AND users.id = 2 
    assert_not michael.following?(archer)

    # michaelがarcherをフォローする
    # INSERT INTO relationships (follower_id, followed_id, created_at, updated_at) 
    #                    VALUES (          1,           2,       date,       date)
    michael.follow(archer)

    # michaelがarcherをフォローしているか
    assert michael.following?(archer)

    # archerはmichaelにフォローされているか
    # (archerのfollowersにmichaelは含まれるか)
    assert archer.followers.include?(michael)

    # michaelがarcherをアンフォローする
    # SELECT relationships.* FROM relationships 
    # WHERE relationships.follower_id = 1 AND relationships.followed_id = 2
    # ↑で follower_id = 1 かつ followd_id = 2のrelationshipsを取得(relationships.id = 3が取得される)
    # DELETE FROM relationships WHERE relationships.id = 3 
    michael.unfollow(archer)

    # michaelがarcherをフォローしていないか
    assert_not michael.following?(archer)
  end

  test "feed should have the right posts" do
    # test/fixtures/relationships.ymlにて↓定義
    # michaelはlanaをフォローしている
    # lanaはmichaelをフォローしている
    # archerはmichaelをフォローしている
    michael = users(:michael)
    archer  = users(:archer)
    lana    = users(:lana)

    # lanaの投稿が、michaelのfeed(投稿の一覧)に含まれているか
    lana.microposts.each do |post_following|
      assert michael.feed.include?(post_following)
    end

    # michaelの投稿が、michaelのfeedに含まれているか
    michael.microposts.each do |post_self|
      assert michael.feed.include?(post_self)
    end

    # archerの投稿が、michaelのfeedに含まれていないか
    archer.microposts.each do |post_unfollowed|
      assert_not michael.feed.include?(post_unfollowed)
    end
  end
end
