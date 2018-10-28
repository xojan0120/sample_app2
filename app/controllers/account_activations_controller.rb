class AccountActivationsController < ApplicationController

  def edit

    user = User.find_by(email: params[:email])

    # ユーザーが存在する && ユーザーが無効 && トークンparams[:id]と有効化ダイジェストが一致
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate

      # log_inメソッドはapp/helpers/sessions_helper.rbに有り
      # session[:user_id] = user.id
      log_in user

      flash[:success] = "Account activated!"
      # 下記はredirect_to user_url(user)と同じ意味
      # user_url(user)は 192.168.33.10:3000/users/1といったURLを返す
      redirect_to user 
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
