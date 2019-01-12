class RelationshipsController < ApplicationController
  # アクションの前に、app/controllers/application_controller.rbのlogged_in_userメソッドを実行
  # このメソッドはログイン済みユーザかどうか確認し、ログインしていなければ、login_urlへリダイレクトする
  before_action :logged_in_user

  def create
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    # respond_toメソッドはリクエストの種類によって応答を場合分けするときに使えるメソッド
    # respond_toメソッドはブロック内を上から順に実行するわけではなく、
    # いずれかの1行が実行される
    respond_to do |format|
      #format.html { redirect_to @user }
      format.js
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    # respond_toメソッドはリクエストの種類によって応答を場合分けするときに使えるメソッド
    # respond_toメソッドはブロック内を上から順に実行するわけではなく、
    # いずれかの1行が実行される
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
end
