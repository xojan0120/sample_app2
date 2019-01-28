class DirectMessagesController < ApplicationController
  def user_index
    respond_to do |format|
      #format.html
      format.js
    end
  end

  def to_search
    @search_name = params[:user] ? params[:user][:name] : ""
    if @search_name.present?
      @search_result_user = User.find_by_name(@search_name)
    end

    respond_to do |format|
      #format.html
      format.js
    end
  end
end
