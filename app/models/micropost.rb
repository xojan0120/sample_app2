class Micropost < ApplicationRecord
  after_save :register_reply
  # Micropostモデルは1つのUserモデルに属する
  belongs_to :user

  # Micropostモデルは複数のReplyモデルを持つ
  # dependent: :destroyは、Micropostが破棄された場合、それに依存(dependent)して、
  # Repliesも破棄されるという意味
  has_many :replies, dependent: :destroy

  #dpendent: :destroy default_scopeメソッドは、データベースから要素を取得したときのデフォルトの順序を指定するメソッド
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

  # ------------------------------------------------------------------
  # アップロードされた画像のサイズをカスタムバリデーションで検証する
  # ------------------------------------------------------------------
  # カスタムメソッド版(当クラスのprivateメソッドで定義)
  # validatesではなく、validateを使う。オプションは渡せない。
  #validate :picture_size
  
  # カスタムバリデータ(レコード)版(app/validators/picture_size_validator.rbで定義)
  # validatesではなく、validates_withを使う。オプションを渡せる。options[キー]で取得。
  #validates_with PictureSizeValidator
  #validates_with PictureSizeValidator, { minimum: 1.byte }
  #validates_with PictureSizeValidator, minimum: 1.byte

  # カスタムバリデータ(属性)版(app/validators/size_validator.rbで定義)
  # オプションを渡せる。
  #
  # Hashの場合は、options[キー]で取得。
  #validates :picture, size: { minimum: 1.byte }
  validates :picture, size: { maximum: 5.megabytes }
  #validates :picture, size: { minimum: 1.megabytes, maximum: 5.megabytes }
  #
  # Range,Arrayの場合は、options[:in]で取得。
  #validates :picture, size: 1.megabytes..5.megabytes
  #validates :picture, size: [1.megabytes, 5.megabytes]
  #
  # Hash,Range,Array以外の場合は、options[:with]で取得。
  #validates :picture, size: 5.megabytes

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
  
=begin
  def self.including_replies(user_id)
    # following_idsとはrailsが自動的に生成したメソッドである。
    # Userモデルでhas_many :followingを定義したことで生成される。
    # メソッド名の通り、あるUserがフォローしているユーザのidの配列を返す
    # なお、下記では(:following_ids)に直接、following_idsによるidの配列がセットされてしまうように
    # 見えるが、実際は、railsが自動的に配列からidのカンマ区切りの状態に変換してくれる。
    #following_ids = "SELECT followed_id FROM relationships
    #                 WHERE follower_id = :user_id"

    # Micropostsテーブルから、下記のいずれか条件のマイクロポストを取得する
    #   自分がフォローしている人
    #   自分のマイクロポスト
    #   返信先が自分になっているマイクロポスト

    # 書き方A
    #Micropost.where("   user_id     IN (:following_ids)
    #                 OR user_id     =   :user_id
    #                 OR in_reply_to =   :user_id"       ,following_ids: user.following_ids, user_id: user.id)
    
    # 書き方B
    #Micropost.where("   user_id     IN (#{following_ids})
    #                 OR user_id     =   :user_id
    #                 OR in_reply_to =   :user_id"       , user_id: user_id)

    # 書き方Aより書き方Bのほうが、userのフォロー数が多い場合に効率がよい。
    # 書き方Aの場合は、userがフォローしているユーザIDを
    # Rails側でuser.following_idsで保持するのに対して
    # 書き方Bの場合は、SQL側で保持するため。
    # 集合の操作において、Rails側で処理させるよりSQL側で処理させるほうが効率がよい。
    
    #r1 = Micropost.left_outer_joins(:replies).where(user_id: user_id)
    #r2 = Micropost.left_outer_joins(:replies).merge(Reply.where(reply_to: user_id))
    #r1.or(r2)
    
    #following_ids = Relationship.where(follower_id: user_id).pluck(:followed_id)
    #r1 = Micropost.left_outer_joins(:replies).where(user_id: [user_id] + following_ids)
    #r2 = Micropost.left_outer_joins(:replies).merge(Reply.where(reply_to: user_id))
    #r1.or(r2)
    
    # A.micropostsとrepliesを結合し、自分の投稿を取得
    r1 = Micropost.left_outer_joins(:replies).where(user_id: user_id)

    # B.relationshipsから、フォローしている人のidを取得
    #   micropostsとrepliesを結合し、自分がフォローしている人の投稿を取得
    r2 = Relationship.select(:followed_id).where(follower_id: user_id)
    r3 = Micropost.left_outer_joins(:replies).where(user_id: r2)

    # C.micropostsとrepliesを結合し、自分が返信先になっている投稿を取得
    r4 = Micropost.left_outer_joins(:replies).merge(Reply.where(reply_to: user_id))

    # 上記、A,B,Cのいずれかにあてはまる投稿を取得
    r1.or(r3).or(r4)
  end
=end

  def self.including_replies(user_id)
    # Micropostsテーブルから、下記のいずれか条件のマイクロポストを取得する
    #   自分がフォローしている人
    #   自分のマイクロポスト
    #   返信先が自分になっているマイクロポスト

    # フォローしている人のユーザIDを取得
    r_followed_id = Relationship.select(:followed_id).where(follower_id: user_id)

    # 自分が返信先になっている投稿のマイクロポストIDを取得
    r_reply_micropost_id = Micropost.joins(:replies).select(:id).distinct.merge(Reply.where(reply_to: user_id))

    # 自分の投稿を取得
    r1 = Micropost.where(user_id: user_id)
    # フォローしている人の投稿を取得
    r2 = Micropost.where(user_id: r_followed_id)
    # 自分が返信先になっている投稿を取得
    r3 = Micropost.where(id: r_reply_micropost_id)

    r1.or(r2).or(r3)
  end

  # content中から一意ユーザ名を抽出し、全て小文字にして配列で返す。無ければ空配列。
  def unique_names
    # scanについて https://ref.xaio.jp/ruby/classes/string/scan
    content.scan(CommonRegexp::extract_unique_name).flatten.map{ |v| v.downcase }
  end

  private
    def register_reply
      unique_names.each do |unique_name|
        if reply_user = User.find_by(unique_name: unique_name)
          # 下記のいずれでも正しくrepliesに登録できる。
          # buildでもなぜか登録できてしまう。謎。
          #Reply.create(micropost_id: id, reply_to: reply_user.id)
          #replies.build(micropost_id: id, reply_to: reply_user.id)
          replies.create(micropost_id: id, reply_to: reply_user.id)
        end
      end
    end

    # 下記は独自のバリデーション
    # 独自のバリデーションを上記で使うにはvalidatesメソッドではなくvalidateメソッドを使う

    # アップロードされた画像のサイズを検証する
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end
end
