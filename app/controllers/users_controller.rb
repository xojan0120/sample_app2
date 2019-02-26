class UsersController < ApplicationController
  # logged_in_userメソッドはログインユーザかどうか確認し、ログインしていない場合は、login_urlへリダイレクトする。
  # app/controllers/application_controller.rb で定義してある
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :following, :followers]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  def index
    # params[:page]はwill_paginateによって自動的に生成されるパラメータ
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])

    # @userからmicropostsを取得するときにpaginateメソッドで
    # ビューに@micropostsを渡すときの件数(ページ)を制限できる
    # なお、ビュー側には<%= will_paginate %>という埋め込みruby
    # が必要になる。
    @microposts = @user.microposts.paginate(page: params[:page])

    # @userが有効化されていなかったら、root_urlへリダイレクトする
    redirect_to root_url and return unless @user.activated?

    # and returnについて
    # railsでは、1つのアクション内でのrenderメソッドやredirectメソッドは
    # 1度だけにするというルールがある。(複数回呼び出そうとするとエラーになる)
    # そのため、renderやredirectコードのあとにand returnと書くことで
    # 明示的に1度だけ呼ばれるようにすることができる。
    # 参考：https://qiita.com/katsuyuki/items/abf6b8d1cd43915e5586
  end

  def new
    @user = User.new
    @user.build_follower_notification
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user #=> redirect_to user_url(@user)
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    
    # destroyに頼らず手動delete
    #destroy_user(User.find(params[:id]))

    flash[:success] = "User deleted"
    redirect_to users_url
  end

  # @userがフォローしている人たちをページネーションして表示する
  def following
    @title = "Following"
    @user  = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  # @userをフォローしている人たちをページネーションして表示する
  def followers
    @title = "Followers"
    @user  = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private
    def user_params
      params.require(:user).permit(:name,
                                   :email,
                                   :password,
                                   :password_confirmation,
                                   :unique_name,
                                   follower_notification_attributes: [:id, :enabled]
                                  )
    end

    # beforeアクション
    
    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end

    #def destroy_user(user)
    #  # 自分の投稿の画像を全削除
    #  remove_images(user.microposts, "picture")
    #  # 自分の投稿を全削除
    #  user.microposts.delete_all
    #  # 自分のフォロー関係を全削除
    #  user.active_relationships.delete_all
    #  # 自分のフォロワー関係を全削除
    #  user.passive_relationships.delete_all
    #  # 自分宛に送られたDM表示状態を全削除
    #  user.direct_message_stats.delete_all
    #  # 自分が送ったDMの表示状態を全削除
    #  direct_messages = user.direct_messages
    #  DirectMessageStat.where(direct_message: direct_messages).delete_all
    #  # 自分のDMの画像を全削除
    #  remove_images(user.direct_messages, "picture")
    #  # 自分のDMを全削除
    #  user.direct_messages.delete_all
    #  # 自分のユーザルームを全削除
    #  user.user_rooms.delete_all
    #  # 自分のユーザを削除
    #  user.delete
    #end

    #def remove_images(active_record_relation, column_name)
    #  active_record_relation.each do |record|
    #    if record.send("#{column_name}?")
    #      record.send("remove_#{column_name}!")
    #      logger.debug "remove_#{column_name}! from #{record.inspect}"
    #    end
    #  end
    #end
end
