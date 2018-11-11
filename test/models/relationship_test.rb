require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase

  def setup
    # フォローする側の人：michael、フォローされる側の人：archer
    @relationship = Relationship.new(follower_id: users(:michael).id,
                                     followed_id: users(:archer).id)
  end

  test "should be valid" do
    # @relationshipが有効か？
    # ここで有効になるためには、Relaitionshipのリスト14.1で定義した制約 
    # add_index :relationships, [:follower_id, :followed_id], unique: true
    # ↑つまり、follower_idとfollowed_idの複合キーがユニークである必要がある
    # ここでtest/fixtures/relationships.ymlにこの制約に反するデータの定義が
    # されていると無効になってしまいテストに失敗する
    # 制約に反するデータとは例えば↓
    # one:
    #   follower_id: 1
    #   followed_id: 1
    # 
    # two:
    #   follower_id: 1
    #   followed_id: 1
    assert @relationship.valid?
  end

  # folower_idは必須になっているかのテスト
  test "should require a follwer_id" do
    # ここでfollower_idが必須になるのは、app/models/relationship.rbで
    # belongs_to :follower が定義されることで必須になる模様。
    # validates :follower_id, presence: trueでなるわけではない模様。。。
    @relationship.follower_id = nil
    assert_not @relationship.valid?
  end

  # folowed_idは必須になっているかのテスト
  test "should require a follwed_id" do
    # ここでfollower_idが必須になるのは、app/models/relationship.rbで
    # belongs_to :followed が定義されることで必須になる模様。
    # validates :followed_id, presence: trueでなるわけではない模様。。。
    @relationship.followed_id = nil
    assert_not @relationship.valid?
  end
end
