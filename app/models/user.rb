class User < ApplicationRecord
  # Userモデルは複数のMicropostモデルを持つ
  # dependent: :destroyは、Userが破棄された場合、それに依存(dependent)して、
  # Micropostsも破棄されるという意味
  has_many :microposts, dependent: :destroy

  # Userモデルは複数のActiveRelationshipモデルを持つ。
  # ここで、ActiveRelationshipというモデルは存在せず、存在するのはRelationshipモデルである。
  # ActiveRelationshipとは、フォローする側からみたRelationshipのことである。
  # has_many :active_relationshipsだけだと、その名称からrailsは存在しないActiveRelationshipsモデルを
  # 探そうとしてしまうため、class_name: "Relationship"と指定することで、そのモデルを明示している。
  # さらに、Userモデルからフォローしている人を検索するためには、Relationshipモデルのfollower_idを
  # 検索しなければいけないため、これを外部キーとして明示するために、foreign_key: "follower_id"を指定している。
  #
  # Userはたくさんのactive_relationships(フォローしている人との関係)を持っている。
  # active_relationshipsのモデルはRelationshipである。
  # Userからactive_relationships(Relationship)を取得するときの外部キーはRelationshipのfollower_idである。
  # → SELECT * FROM relationships WHERE follower_id = 「user.id」
  # Userが削除されれば、Relationshipからもuser.id = relationship.follower_idのレコードが削除される。
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy

  # Userモデルは複数のPassiveRelationshipモデルを持つ。
  # ここで、PassiveRelationshipというモデルは存在せず、存在するのはRelationshipモデルである。
  # PassiveRelationshipとは、フォローされる側からみたRelationshipのことである。
  # has_many :passive_relationshipsだけだと、その名称からrailsは存在しないPassiveRelationshipsモデルを
  # 探そうとしてしまうため、class_name: "Relationship"と指定することで、そのモデルを明示している。
  # さらに、Userモデルからフォローされている人を検索するためには、Relationshipモデルのfollowed_idを
  # 検索しなければいけないため、これを外部キーとして明示するために、foreign_key: "followed_id"を指定している。
  #
  # Userはたくさんのpassive_relationships(フォローされている人との関係)を持っている。
  # passive_relationshipのモデルはRelationshipである。
  # Userからpassive_relationships(Relationship)を取得するときの外部キーはRelationshipのfollowed_idである。
  # → SELECT * FROM relationships WHERE followed_id = 「user.id」
  # Userが削除されれば、Relationshipからもuser.id = relationship.followed_idのレコードが削除される。
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy

  # 1人のユーザーはいくつもの「フォローする」「フォローされる」という関係性がある（多対多）
  # ここでは、Userモデルが複数のfollowed(followedはフォローされる人、followedの集合体がfollowing)を持つことを表す。
  # このアプリではfollowingの単体はfollowedとしているが、英語上followingはfollowedの複数形ではないため、
  # railsはfollowingから単数形としてfollowedを推測できない。だからsource: :followedと明示することで、
  # followingの単数形はfollowedと知ることができる。
  # ↓の一文により、Usersモデルは複数のfollowedを持ち、sourceに明示されたfollowedに+ "_id"のfollowed_idを用いて、
  # relationshipsテーブル(active_relationships)から対象のユーザ(followed)を取得できるようになる。
  # なお、これにより、Userがフォローしている人の配列を取得できるfollowingメソッドが使えるようになる。
  #
  # Userはたくさんのfollowing(フォローした人たちの集合)を持つ。
  # followingを取得するときは、active_relationships(フォローしている人との関係)を通す。
  # その際、active_relationships(Relationship)のfollowed_idを参照元とする。
  # → SELECT * FROM users INNER JOIN relationships ON users.id = relationships.followed_id
  #             WHERE relationships.follower_id = 「user.id」
  has_many :following, through: :active_relationships,  source: :followed

  # 1人のユーザーはいくつもの「フォローする」「フォローされる」という関係性がある（多対多）
  # ここでは、Userモデルが複数のfollower(followerはフォローする人、followerの集合体がfollowers)を持つことを表す。
  # followedとfollowdingの関係の時は、followingからfollowedをrailsが推測できないため、source: :followedと
  # 明示していたが、ここでは本来ならsource: :followerを明示する必要はない。敢えて、対照的に比較できるよう明示しているだけ。
  # ↓の一文により、Usersモデルは複数のfollowerを持ち、sourceに明示されたfollowerに+ "_id"のfollower_idを用いて、
  # relationshipsテーブル(passive_relationships)から対象のユーザ(follower)を取得できるようになる。
  # なお、これにより、Userをフォローしている人の配列を取得できるfollowersメソッドが使えるようになる。
  #
  # Userはたくさんのfollowers(フォローされている人たちの集合)を持つ。
  # followersを取得するときは、passive_relationships(フォローされている人との関係)を通す。
  # その際、passive_relationships(Relationship)のfollower_idを参照元とする。
  # → SELECT * FROM users INNER JOIN relationships ON users.id = relationships.follower_id
  #             WHERE relationships.followed_id = 「user.id」
  has_many :followers, through: :passive_relationships, source: :follower

  # dependent: :delete_allは、上記destroyと同じく、それに依存する子オブジェクトも
  # 破棄してくれるが、違いは一括で破棄してくれる点である。
  # destroyはDELETE文を削除する子オブジェクトの件数分発行する。
  # delete_allはDELETE文を1回発行する。
  # 但し、delete_allの場合は、コールバックやバリデーションを介さず、
  # 直接SQLが実行される点に注意。
  has_many :direct_messages,      dependent: :delete_all
  has_many :direct_message_stats, dependent: :delete_all
  has_many :user_rooms,           dependent: :delete_all
  has_many :rooms, through: :user_rooms

  attr_accessor :remember_token, :activation_token, :reset_token

  before_save   :downcase_email
  before_save   :downcase_unique_name

  # before_saveとの違いは、saveは作成・更新時、createは作成時のみ実行される
  before_create :create_activation_digest

  validates :name, presence: true, length: { maximum: 50 }

  validates :email, presence: true,
                    length: { maximum: 255 },
                    format: { with: CommonRegexp::format_email },
                    uniqueness: { case_sensitive: false }

  validates :unique_name, presence: true, length: { in: Settings.unique_name.length.minimum..Settings.unique_name.length.maximum },
                          format: { with: CommonRegexp::format_unique_name },
                          uniqueness: { case_sensitive: false }

  has_secure_password

  # ここでallow_nil: trueにより空パスワードを許可しているが、has_secure_passwordによる
  # 空パスワードのチェックも行われるため、新規登録時は空パスワードは通らない。
  # なお、以下でallow_nil: trueがないと、新規登録時バリデーションエラーがあった場合に、
  # 二重で空パスワードエラーが発生するという不都合もあった。
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    # ActiveModel::SecurePassword.min_cost はテスト環境だとtrue、それ以外だとfalse
    # 参考：https://qiita.com/shinya_ichinoseki/items/cedde49adc1d1e886195
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  # 第一引数：属性名、第二引数：トークン
  def authenticated?(attribute, token)

    # Usersテーブルの#{attribute}_digest属性から、保存されている
    # ダイジェストを取得する
    digest = send("#{attribute}_digest")

    return false if digest.nil?

    # 下記でトークンがダイジェストと一致するかの論理値を返す
    BCrypt::Password.new(digest).is_password?(token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    # self.update_attributeでもOKだが、
    # selfはモデル内では必須ではない。
    update_attribute(:remember_digest, nil)
  end

  # アカウントを有効にする
  def activate
    # self.update_attributeでもOKだが、
    # selfはモデル内では必須ではない。
   
    # update_attributeが2回以上呼ばれる場合は、update_columnsで
    # まとめることができ、データベースへの問い合わせが１回で済む
    # update_attribute(:activated,     true)
    # update_attribute(:activated_at,  Time.zone.now)
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    # UserMailerはapp/mailers/user_mailer.rbに有り
    # account_activationメソッドは引数(userオブジェクト)のuser宛にアカウント有効化メールを送信する
    UserMailer.account_activation(self).deliver_now
  end

  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    # update_attribute(:reset_digest, User.digest(reset_token))
    # update_attribute(:reset_sent_at, Time.zone.now)
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    # UserMailerはapp/mailers/user_mailer.rbに有り
    # password_resetメソッドは引数(userオブジェクト)のuser宛にパスワード再設定のメールを送信する
    UserMailer.password_reset(self).deliver_now
  end

  # パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    # パスワード再設定メール送信時刻 < 現時刻より2時間以上前(早い) の場合、true
    reset_sent_at < 2.hours.ago
  end

  def feed
    # following_idsとはrailsが自動的に生成したメソッドである。
    # Userモデルでhas_many :followingを定義したことで生成される。
    # メソッド名の通り、あるUserがフォローしているユーザのidの配列を返す
    # なお、下記では(?)に直接、following_idsによるidの配列がセットされてしまうように
    # 見えるが、実際は、railsが自動的に配列からidのカンマ区切りの状態に変換してくれる。

    # 書き方１
    # 良くない点：following_idsメソッドでフォローしているユーザをデータベースへ
    # 問い合わせし、さらにMicropost.whereにより再度データベースへ問い合わせている
    # Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)
    
    # 書き方２
    # これは書き方１の？ではなくシンボルを使った別の書き方
    # Micropost.where("user_id IN (:following_ids) OR user_id = :user_id",
    #                 following_ids: following_ids, user_id: id)

    # 書き方３
    # 良い点：ここのfollowing_idsは書き方１のときのfollowing_idsメソッドではなく
    # ただのSQL文である。これをMicropost.whereの中にいれることで、１文のSQLで
    # あるユーザーがフォローしている全てのユーザIDを取得という意味になり、
    # より効率的にデータを取得できる。
   
    # Relationshipsテーブルから、自分がフォロワーになっている（つまり自分が
    # フォローしている）人たちのID（followed_id）を取得
    #following_ids = "SELECT followed_id FROM relationships
    #                 WHERE follower_id = :user_id"

    # Micropostsテーブルから、上記のID（自分がフォローしている人たちのID）
    # に一致する、または、自分のマイクロポストを取得する
    
    # Micropost.where("user_id IN (#{following_ids})
    #                  OR user_id = :user_id", user_id: id)
    
    Micropost.including_replies(id)
  end

  # ユーザーをフォローする
  def follow(other_user)
    # followingはfollowed(フォローされる側の人)の集合
    following << other_user
  end

  # ユーザーをフォロー解除する
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # 現在のユーザーがフォローしてたらtrueを返す
  def following?(other_user)
    # followingはfollowed(フォローされる側の人)の集合
    following.include?(other_user)
  end

  def following_search(query_word)
    # 開発環境のsqlite3において、LIKE演算子は大文字小文字を区別しないため、
    # LOWERは不要だが、他DBの場合を考慮してLOWERしておく。
    
    # 書き方1
    #r1 = following.where("name        LIKE LOWER(?)", "%#{query_word}%")
    #r2 = following.where("unique_name LIKE LOWER(?)", "%#{query_word}%")
    #r1.or(r2)
    
    # 書き方2
    #following.where("name LIKE LOWER(?) OR unique_name LIKE LOWER(?)", "%#{query_word}%", "%#{query_word}%")

    # 書き方3(ransack使用)
    # 補足: query_wordが空だと全件返されるのでlimitで制限する
    following.ransack(name_or_unique_name_cont: query_word).result.limit(10)
  end

  def send_dm(room, content = "", picture_data_uri = "")
    direct_message = direct_messages.build(content: content, picture_data_uri: picture_data_uri, room: room)

    # テスト用。意図的にエラーを起こす場合は、"raise"と入力。
    direct_message = direct_messages.build(content: nil, picture_data_uri: nil, room: room) if content == "raise"

    if direct_message.save
      room.users.each do |user|
        #DirectMessageStat.create(display: true, user: user, direct_message: dm)
        direct_message.direct_message_stats.create(display: true, user: user)
      end
    end
    direct_message
  end

  def hide_dm(direct_message)
    direct_message.get_state_for(self).invisible
  end

  #def latest_dm_users(count)
  #  users = Array.new
  #  # 自分が送った直近DM(room毎)をcount件取得
  #  dms = direct_messages.select([:user_id, :room_id]).order(created_at: :desc).distinct([:user_id, :room_id]).limit(count)
  #  dms.each do |direct_message|
  #    users << direct_message.received_users
  #  end
  #  users.flatten
  #end
  
  def latest_dm_users(limit)
    users = Array.new

    # limitより、現在のDMのroom数のほうが少なければ、room数分の
    # 宛先ユーザを取得する。こうしておかないと、room数1で、一人の
    # 相手とだけDMのやりとりをずっとしていた場合、そのDM数分だけ
    # eachすることになるのを回避するため。
    # 但し、これは1roomに相手が1人だけという前提である。
    # 2人以上いた場合は、2人目以降のユーザが取得できない問題がある。
    count = direct_messages.select(:room_id).distinct(:room_id).count
    if limit > count
      limit = count
    end

    direct_messages.order(created_at: :desc).each do |direct_message|
      direct_message.received_users.each do |user|
        users << user unless users.include?(user)
        return users if users.size >= limit
      end
    end

    return users
  end

  private

    # メールアドレスをすべて小文字にする
    def downcase_email
      self.email.downcase!
    end

    # 一意ユーザ名をすべて小文字にする
    def downcase_unique_name
      self.unique_name.downcase!
    end

    # 有効化トークンとダイジェストを作成および代入する
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token) 
    end
end
