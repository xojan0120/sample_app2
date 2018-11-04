class Micropost < ApplicationRecord
  # MicropostオブジェクトはUserオブジェクトに属する
  belongs_to :user

  # default_scopeメソッドは、データベースから要素を取得したときのデフォルトの順序を指定するメソッド
  # 特定の順序にするためには、default_scopeの引数にorderを与える。
  # ここでは、作成日時の降順でデータを取得するの意味
  default_scope -> { order(created_at: :desc) }

  # CarrierWaveに画像と関連付けたモデルを伝えるためにmount_uploaderというメソッドを使用
  # このメソッドは、引数に属性名のシンボルと生成されたアップローダーのクラス名を取る
  mount_uploader :picture, PictureUploader

  # 上記の -> は Proc、lambda(もしくは無名関数)と呼ばれる手続きオブジェクトを作成する文法
  # a = -> { Time.now }  変数aにTime.nowという手続きオブジェクトを代入する
  # a.callで手続きオブジェクト{ Time.now }の部分が実行される。
  # 参考：http://melborne.github.io/2014/04/28/proc-is-the-path-to-understand-ruby/

  # user_id属性がnilでないかの検証 ( presenceは"存在" )
  validates :user_id, presence: true

  # content属性がnilでないか、長さが最大140であるかの検証
  validates :content, presence: true, length: { maximum: 140 }

  # アップロードされた画像のサイズを検証する
  validate :picture_size

  private

    # 下記は独自のバリデーション
    # 独自のバリデーションを上記で使うにはvalidatesメソッドではなくvalidateメソッドを使う

    # アップロードされた画像のサイズを検証する
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end
end
