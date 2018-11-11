class Relationship < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  # ↓の２行はfollwer_idとfollowd_idがそれぞれ必須であることを
  # 意味するが、実はRails5からは記載不要である。
  # なぜなら、上記のbelongs_toにより必須が定義されるためである。
  # 参考：https://qiita.com/iguchi1124/items/218e35a145f372062ea4
  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
