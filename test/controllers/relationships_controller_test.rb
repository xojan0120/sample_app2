require 'test_helper'

class RelationshipsControllerTest < ActionDispatch::IntegrationTest

  # followボタンを押したとき、ログインしてなかったら、
  # Relationshipテーブルのカウントは変わらず、login_urlに
  # リダイレクトされるかどうか
  test "create should require logged-in user" do
    assert_no_difference 'Relationship.count' do
      post relationships_path
    end
    assert_redirected_to login_url
  end

  # unfollowボタンを押したとき、ログインしてなかったら、
  # Relationshipテーブルのカウントは変わらず、login_urlに
  # リダイレクトされるかどうか
  test "destroy should require logged-in user" do
    assert_no_difference 'Relationship.count' do
      delete relationship_path(relationships(:one))
    end
    assert_redirected_to login_url
  end
end
