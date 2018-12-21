class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  private

    # ログイン済みユーザーかどうか確認
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

    # current_userの全てのマイクロポストを取得する
    def current_user_feed(page)
      # ここのfeedは app/models/user.rbで定義されているメソッド
      current_user.feed.paginate(page: page)
    end
end
