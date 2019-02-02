class DirectMessagesController < ApplicationController
  def user_index
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
    @user_name = User.find(params[:user_id]).name
    respond_to do |format|
      format.js
    end
  end

  def create
    dm = DirectMessage.new(direct_message_params)
    debugger
  end

  private

    def direct_message_params
      params.require(:direct_message).permit(:content, :picture)
    end
  
end
