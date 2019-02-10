class DirectMessagesController < ApplicationController
  def user_index
    @latest_dm_users = current_user.latest_dm_users(10)
    respond_to do |format|
      format.js
    end
  end

  def to_select
    respond_to do |format|
      format.js
    end
  end

  # インクリメンタル検索(JSON版用)
  #def to_search
  #  if params[:query_word].present?
  #    users = current_user.following_search(params[:query_word])
  #    render json: users
  #  end
  #end

  def to_search
    if params[:query_word].present?
      @users = current_user.following_search(params[:query_word])
    else
      @users = []
    end

    respond_to do |format|
      format.js
    end
  end

  def index
    @partner = User.find(params[:user_id])
    member = [current_user,@partner]

    @room = Room.exist?(member) ? Room.pick(member) : Room.make(member)
    @direct_messages = @room.direct_messages_for(current_user)

    respond_to do |format|
      format.js
    end
  end

  def create
    room = current_user.rooms.find(session[:room_id])
    content = params[:direct_message][:content]
    picture = params[:direct_message][:picture]
    @direct_message = current_user.send_dm(room, content, picture)
    #redirect_to direct_messages_index_path(user_id: 1)
  end

  private

    #def direct_message_params
    #  params.require(:direct_message).permit(:content, :picture,)
    #end
  
end
