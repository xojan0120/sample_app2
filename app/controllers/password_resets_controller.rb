class PasswordResetsController < ApplicationController
  before_action :get_user,         only: [:edit, :update]
  before_action :valid_user,       only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)

    if @user
      # パスワード再設定用トークンの作成
      @user.create_reset_digest

      # パスワード再設定用メールの送信
      @user.send_password_reset_email

      flash[:info] = "Email sent with password reset instructions"

      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def edit
  end

  def update
    # paramsパスワードが空だったら、エラーメッセージを@userに追加し、
    # パスワード再設定用ビュー(edit.html.erb)を表示する
    if params[:user][:password].empty?
      @user.errors.add(:password, :blank)
      render 'edit'
    # パスワードが空でなければ、paramsパスワードとparams確認用パスワードで
    # データベースのpassword_digestを更新する。
    #    パスワードの実装については、Userモデルのhas_secure_passwordメソッドにより実装されている。
    #    Userモデルでhas_secure_passwordメソッドが呼び出されており、かつ、Userモデルにpassword_digest属性が
    #    ある場合、Userモデルには、仮想的な属性であるpasswordとpassword_confirmationが使えるようになる。
    #    詳細は→ https://railstutorial.jp/chapters/modeling_users?version=5.1#sec-adding_a_secure_password
    # password_digestの更新に成功したら、@userでログインし、更新成功のメッセージを表示、@userのホーム画面(users#show)へリダイレクトする。
    elsif @user.update_attributes(user_params)
      log_in @user

      # ここで再設定用ダイジェストをnilにするのは、例えば、共用PCなどで、あるユーザがパスワードを再設定したとする。
      # その後ログアウトしたとしても、他のユーザがブラウザの履歴から、パスワード再設定用URLを探し出しアクセスしたとき、
      # 再設定用URL期限切れの2時間以内であれば、再びパスワード再設定用URLにアクセスでき、パスワードの更新ができてしまうため。
      # しかも、パスワード更新後は自動的にログイン状態になってしまう。これを防ぐため。
      @user.update_attribute(:reset_digest, nil)

      flash[:success] = "Password has been reset."
      redirect_to @user
    # 無効なパスワード(上記の@user.update_attributes(user_params)が失敗した場合)
    else
      render 'edit'
    end
  end

  private

    def user_params
      # 受け取りパラメータは、:user属性を必須とし、パスワード、確認用パスワードの属性を許可する
      # つまりparams[:user]を必須とし、params[:user][:password]とparams[:user][:password_confirmation]を受け取ることを許可する
      params.require(:user).permit(:password, :password_confirmation)
    end

    def get_user
      @user = User.find_by(email: params[:email])
    end

    # 正しいユーザーかどうか確認する
    def valid_user
      # unless (ユーザーが存在する && ユーザーが有効である && データベースに再設定用トークン(params[:id])のダイジェスト(ハッシュ)がある)
      unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    # トークンが期限切れかどうか確認する
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end
end
