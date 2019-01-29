class DirectMessagesController < ApplicationController
  def user_index
    respond_to do |format|
      #format.html
      format.js
    end
  end

  def to_select
    respond_to do |format|
      #format.html
      format.js
    end
  end

  def to_search
    if params[:query_word].present?
      result = current_user.following_search(params[:query_word])
      render json: result
    else
      render json: []
    end
  end
  
  #def to_search
  #  @search_name = params[:user] ? params[:user][:name] : ""
  #  if @search_name.present?
  #    @search_result_user = current_user.following_search(@search_name)
  #  end

  #  respond_to do |format|
  #    #format.html
  #    format.js
  #  end
  #end
end
