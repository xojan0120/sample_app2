require 'test_helper'

class MicropostTest < ActiveSupport::TestCase

  def setup

    # test/fixtures/users.ymlで定義したmichaelを取得
    @user = users(:michael)

    # このコードは慣習的に正しくない
    # @micropost = Micropost.new(content: "Lorem ipsum", user_id: @user.id)
    # 下記は、userに紐付いた新しいmicropostオブジェクトを返す
    @micropost = @user.microposts.build(content: "Lorem ipsum")
    # 上記のbuildメソッドが使えるようになるためには、
    # Micropostモデルにbelogns_to :user(この定義は、rails generate modelするときに、user:referencesがあると、自動的に記述される)
    # Userモデルにhas_many :microposts の両方の定義が必要
  end

  test "should be valid" do
    # valid?(有効か？)メソッドはActiveRecordオブジェクトで使えるメソッドで、
    # オブジェクトにバリデーションによるエラーがないかどうかを真偽で返す
    # invalid?(無効か？)もある。
    assert @micropost.valid?
  end

  # micropost.user_idは空でない
  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  # micropost.contentは空でない
  test "content should be present" do
    @micropost.content = "   "
    assert_not @micropost.valid?
  end

  # micropost.contentは140文字以下である
  test "content should be at most 140 characters" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end

  # Micropostテーブルから取得できる最初のmicropostオブジェクトは、
  # fixturesの:most_recentとして定義したmicropostと同じである。
  # ※:most_recentのcreated_atはTime.zone.nowにしてある。
  test "order should be most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end

end
