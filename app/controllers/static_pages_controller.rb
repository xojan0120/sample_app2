class StaticPagesController < ApplicationController
  def home
    if logged_in?
      @micropost = current_user.microposts.build

      # ここのfeedは app/models/user.rbで定義されているメソッド
      # current_userの全てのマイクロポストを取得する
      #@feed_items = current_user.feed.paginate(page: params[:page])
      
      @feed_items = current_user_feed(params[:page])
    end
  end

  def help
  end

  def about
  end
  
  def contact
  end
end
