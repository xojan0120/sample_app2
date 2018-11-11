class User < ApplicationRecord
  # Userモデルは複数のMicropostモデルを持つ
  # dependent: :destroyは、Userが破棄された場合、それに依存(dependent)して、
  # micropostsも破棄されるという意味
  has_many :microposts, dependent: :destroy

  # Userモデルは複数のActiveRelationshipモデルを持つ。
  # ここで、ActiveRelationshipというモデルは存在せず、存在するのはRelationshipモデルである。
  # ActiveRelationshipとは、フォローする側からみたRelationshipのことである。
  # has_many :active_relationshipsだけだと、その名称からrailsは存在しないActiveRelationshipsモデルを
  # 探そうとしてしまうため、class_name: "Relationship"と指定することで、そのモデルを明示している。
  # さらに、Userモデルからフォローしている人を検索するためには、Relationshipモデルのfollower_idを
  # 検索しなければいけないため、これを外部キーとして明示するために、foreign_key: "follower_id"を指定している。
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
  has_many :following, through: :active_relationships,  source: :followed

  # 1人のユーザーはいくつもの「フォローする」「フォローされる」という関係性がある（多対多）
  # ここでは、Userモデルが複数のfollower(followerはフォローする人、followerの集合体がfollowers)を持つことを表す。
  # followedとfollowdingの関係の時は、followingからfollowedをrailsが推測できないため、source: :followedと
  # 明示していたが、ここでは本来ならsource: :followerを明示する必要はない。敢えて、対照的に比較できるよう明示しているだけ。
  # ↓の一文により、Usersモデルは複数のfollowerを持ち、sourceに明示されたfollowerに+ "_id"のfollower_idを用いて、
  # relationshipsテーブル(passive_relationships)から対象のユーザ(follower)を取得できるようになる。
  has_many :followers, through: :passive_relationships, source: :follower

  attr_accessor :remember_token, :activation_token, :reset_token
  before_save   :downcase_email
  before_create :create_activation_digest
  validates :name, presence: true, length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password

  # ここで空パスワードを許可しているが、has_secure_passwordによるバリデーション内には
  # 空パスワードのチェックが行われるため、実際には空パスワードは通らない。
  # なお、以下で空パスワードをチェックすると、バリデーションエラーがあった場合に、
  # 二重で空パスワードエラーが発生してしまうため、下記ではallow_nil: trueしておくのが正解。
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
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
    following_ids = "SELECT followed_id FROM relationships
                     WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
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

  private

    # メールアドレスをすべて小文字にする
    def downcase_email
      self.email.downcase!
    end

    # 有効化トークンとダイジェストを作成および代入する
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token) 
    end
end
