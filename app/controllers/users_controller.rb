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
    # 下記の文はこうかける。redirect_toやrenderのあとも処理は続くため
    # そこで処理を終わらせるためにはreturnしてあげればよい。
    # しかし、他のredirect_toじゃそんなことしてないし、ここでなぜ突然
    # returnしだしたのか？など、return無くても動作は問題なさそう。
    # unless @user.activated?
    #   redirect_to root_url
    #   return
    # end
    redirect_to root_url and return unless @user.activated?
  end

  def new
    @user = User.new
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
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :unique_name)
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
end
