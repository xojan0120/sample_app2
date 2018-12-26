class Micropost < ApplicationRecord
  # MicropostオブジェクトはUserオブジェクトに属する
  belongs_to :user

  # default_scopeメソッドは、データベースから要素を取得したときのデフォルトの順序を指定するメソッド
  # 特定の順序にするためには、default_scopeの引数にorderを与える。
  # ここでは、作成日時の降順でデータを取得するの意味
  default_scope -> { order(created_at: :desc) }

  # スコープは、関連オブジェクトやモデルへのメソッド呼び出しとして参照される
  # よく使用されるクエリを指定することができる。ActiveRecord::Relationオブジェクト
  # を返す。スコープはクラスメソッドの定義と同じで、どちらを使用するかは
  # お好み。但し、引数を使用するならば、クラスメソッドとして定義することが
  # 推奨されているので、
  # https://railsguides.jp/active_record_querying.html#%E3%82%B9%E3%82%B3%E3%83%BC%E3%83%97
  #scope :including_replies, ->(id) { where("in_reply_to = ?", id) }

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
  # validatesではなく、validateは独自のバリデーションを定義するときに使う。
  validate :picture_size

  #def Micropost.including_replies(user_id)
  #  # Relationshipsテーブルから、自分がフォロワーになっている（つまり自分が
  #  # フォローしている）人たちのID（followed_id）を取得
  #  following_ids = "SELECT followed_id FROM relationships
  #                   WHERE follower_id = :user_id"

  #  # Micropostsテーブルから、下記のいずれか条件のマイクロポストを取得する
  #  #   自分がフォローしている人
  #  #   自分のマイクロポスト
  #  #   返信先が自分になっているマイクロポスト
  #  Micropost.where("user_id        IN (#{following_ids})
  #                   OR user_id     =  :user_id
  #                   OR in_reply_to =  :user_id"         , user_id: user_id)
  #  
  #end
  
  def Micropost.including_replies(user)
    # following_idsとはrailsが自動的に生成したメソッドである。
    # Userモデルでhas_many :followingを定義したことで生成される。
    # メソッド名の通り、あるUserがフォローしているユーザのidの配列を返す
    # なお、下記では(:following_ids)に直接、following_idsによるidの配列がセットされてしまうように
    # 見えるが、実際は、railsが自動的に配列からidのカンマ区切りの状態に変換してくれる。
    following_ids = "SELECT followed_id FROM relationships
                     WHERE follower_id = :user_id"

    # Micropostsテーブルから、下記のいずれか条件のマイクロポストを取得する
    #   自分がフォローしている人
    #   自分のマイクロポスト
    #   返信先が自分になっているマイクロポスト

    # 書き方A
    #Micropost.where("   user_id     IN (:following_ids)
    #                 OR user_id     =   :user_id
    #                 OR in_reply_to =   :user_id"       ,following_ids: user.following_ids, user_id: user.id)
    
    # 書き方B
    Micropost.where("   user_id     IN (#{following_ids})
                     OR user_id     =   :user_id
                     OR in_reply_to =   :user_id"       , user_id: user.id)

    # 書き方Aより書き方Bのほうが、userのフォロー数が多い場合に効率がよい。
    # 書き方Aの場合は、userがフォローしているユーザIDを
    # Rails側でuser.following_idsで保持するのに対して
    # 書き方Bの場合は、SQL側で保持するため。
    # 集合の操作において、Rails側で処理させるよりSQL側で処理させるほうが効率がよい。
    
  end

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
