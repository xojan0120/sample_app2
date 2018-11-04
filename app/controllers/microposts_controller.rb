class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: [:destroy]

  def create
    # ここのcurrent_userは変数ではなくメソッド。
    # ログインユーザのuserオブジェクトを返す。
    # app/helpers/sessions_helper.rbに定義有り
    # ログインユーザのマイクロポストをマイクロソフト用パラメータで作成する
    @micropost = current_user.microposts.build(micropost_params)

    # マイクロソフトを保存する。
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"

    # requiest.referrer => 1つ前のURLを返す
    # 1つ前のURLが見つからなかったら、root_urlへリダイレクトする
    #redirect_to request.referrer || root_url
    redirect_back(fallback_location: root_url) # 上記と同じ動きだが、redirect_backはRails5.1から導入された
  end

  private

    def micropost_params
      # パラメータのうち、params[:micropost]を必須とし、params[:micropost][:content]のみ渡す
      params.require(:micropost).permit(:content, :picture)
    end

    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
end
