class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: [:destroy]

  def create
    # ここのcurrent_userは変数ではなくメソッド。
    # ログインユーザのuserオブジェクトを返す。
    # app/helpers/sessions_helper.rbに定義有り
    # ログインユーザのマイクロポストをマイクロポスト用パラメータで作成する
    @micropost = current_user.microposts.build(micropost_params)

    # マイクロポストを保存する。
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      # パターン1 (deleteリンクでエラー)
      #@feed_items = []
      #render 'static_pages/home'

      # パターン2(routesにGET /microposts to: 'static_pages#home'追加)
      # @feed_items = current～がstatic_pages#homeアクションとDRYじゃない
      #@feed_items = current_user.feed.paginate(page: params[:page])
      #render 'static_pages/home'
      
      # パターン3(flashによるエラー表示に難あり)
      # また、redirect_toだと別Controllerにアクションを委譲する
      # ため、@micropostが引き継がれず、@micropost.errorsも
      # 引き継げないため、flashでエラーメッセージを引き継ぐ必要
      # がある。
      # なお、データ保存失敗時に、redirect_toではなくrenderを
      # 使用したほうがいい理由の参考：https://qiita.com/yuki-n/items/2e64a179838c9086ab30
      #@feed_items = current_user.feed.paginate(page: params[:page])
      #flash[:danger] = @micropost.errors.full_messages
      #redirect_to root_url

      # パターン4
      # StaticPagesController#homeアクションの
      # @feed_items = current_user.feed.paginate(page: params[:page])
      # をリファクタリングし、ApplicationControllerで定義し直しておく。
      @feed_items = current_user_feed(params[:page])
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"

    # request.referrer => 1つ前のURLを返す
    # 1つ前のURLが見つからなかったら、root_urlへリダイレクトする
    #redirect_to request.referrer || root_url
    redirect_back(fallback_location: root_url) # 上記と同じ動きだが、redirect_backはRails5.1から導入された
  end

  private

    def micropost_params
      # パラメータのうち、params[:micropost]を必須とし、params[:micropost][:content]のみ渡す
      params.require(:micropost).permit(:content, :picture)

      # メモ：画像アップロードしたときに他のバリデーションでエラーになると、
      # アップロードした画像が消えてユーザ側が不便だが、キャッシュを設定することで
      # 画像を残すことができる。参考：https://blog.otsukasatoshi.com/entry/2016/05/15/150419
    end

    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
end
