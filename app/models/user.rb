class User < ApplicationRecord
  # Userオブジェクトは複数Micropostを持つ
  # dependent: :destroyは、Userが破棄された場合、それに依存(dependent)して、
  # micropostsも破棄されるという意味
  has_many :microposts, dependent: :destroy

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
    Micropost.where("user_id = ?", id)
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
