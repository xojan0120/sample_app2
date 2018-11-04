module SessionsHelper

  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end

  # ユーザーのセッションを永続的にする
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # 渡されたユーザーがログイン済みユーザーであればtrueを返す
  def current_user?(user)
    user == current_user
  end

  # 記憶トークンcookieに対応するユーザーを返す
  def current_user
    # セッションのuser_idを代入
    if (user_id = session[:user_id])
      # @current_userがnilならば、Userテーブルからuser_idで検索し、userオブジェクトを代入する。
      # @current_userがnilでないのなら、そのまま
      @current_user ||= User.find_by(id: user_id)
    # クッキーの暗号化されたuser_idを復号化してuser_idに代入
    elsif (user_id = cookies.signed[:user_id])
      # Userテーブルからuser_idで検索する
      user = User.find_by(id: user_id)
      # userが存在する、かつ、userが認証されている
      if user && user.authenticated?(:remember, cookies[:remember_token])
        # userでログイン。(クッキーにuser.idをセット)
        log_in user
        # userを@current_userとして返す
        @current_user = user
      end
    end
  end

  # 現在ログイン中のユーザーを返す（いる場合）
  #def current_user
  #  if session[:user_id]
  #    # @current_userの値がnilならfind_byする。nilでないならそのまま。
  #    @current_user ||= User.find_by(id: session[:user_id])
  #  end
  #end

  # ユーザーがログインしていればtrue, その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

  # 永続的セッションを破棄する
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # 現在のユーザーをログアウトする
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # 記憶したURL（もしくはデフォルト値）にリダイレクト
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # アクセスしようとしたURLを覚えておく
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end

end
