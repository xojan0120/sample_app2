class RelationshipsController < ApplicationController
  # アクションの前に、app/controllers/application_controller.rbのlogged_in_userメソッドを実行
  # このメソッドはログイン済みユーザかどうか確認し、ログインしていなければ、login_urlへリダイレクトする
  before_action :logged_in_user

  def create
    @user = User.find(params[:followed_id])
    current_user.follow(@user)

    # フォロワー通知メール送信
    fn = @user.follower_notification
    if fn&.enabled?
			log = fn.logs.find_by(follower: current_user)
      if log.nil? || Time.zone.now >= (log.mail_sent_at + Settings.follower_notification[:snooze_limit_hours]) 
				UserMailer.follower_notification(current_user, @user).deliver_later #now
			end
      FollowerNotificationLog.create_or_update(current_user, @user)
    end

    # respond_toメソッドはリクエストの種類によって応答を場合分けするときに使えるメソッド
    # respond_toメソッドはブロック内を上から順に実行するわけではなく、
    # いずれかの1行が実行される
    respond_to do |format|
      format.html { redirect_to @user }
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
