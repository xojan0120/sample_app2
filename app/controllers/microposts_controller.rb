class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: [:destroy]

  def create
    # ここのcurrent_userは変数ではなくメソッド。
    # ログインユーザのuserオブジェクトを返す。
    # app/helpers/sessions_helper.rbに定義有り
    # ログインユーザのマイクロポストをマイクロポスト用パラメータで作成する
    @micropost = current_user.microposts.build(micropost_params)

    # @(.+?)
    #   -> @から始まる任意の1文字以上にマッチ
    # (?:\p{Hiragana}|\p{Katakana}|[ー－、。]|[一-龠々]|\s|　|[\p{P}\p{S}]|\Z)
    #   -> ?: キャプチャしないグループに設定。これがなければ$2でキャプチャできるが、それを敢えてしないことで多少の速度UPらしい。
    #      \p{Hiragana} ひらがなにマッチ
    #      \p{Katakana} カタカナにマッチ
    #      [ー－、。]   括弧内のいずれかにマッチ
    #      [一-龠々]    漢字にマッチ
    #      \s           半角スペースにマッチ
    #      　           全角スペースにマッチ
    #      [\p{P}\p{S}] あらゆるASCII記号にマッチ
    #      \Z           文字列の末尾にマッチ。但し文字列の最後の文字が改行ならばそれの手前にマッチ。
    
    # @返信のunique_name部分を抽出(unique_nameを1個だけ抽出) 
    # re = /@(.+?)(\p{Hiragana}|\p{Katakana}|[ー－、。]|[一-龠々]|\s|　|[\p{P}\p{S}]|\Z)/
    # @micropost.content.match re
    # unique_name = $1

    # こちらのほうがスマート
    unique_name_length_range = "{#{Constants::UNIQUE_NAME_MIN_LENGTH},#{Constants::UNIQUE_NAME_MAX_LENGTH}}"
    re = /@([0-9a-z_]#{unique_name_length_range})/i # /@[0-9a-zA-Z_]{1,15}/
    @micropost.content.match(re)
    reply_user = User.find_by(unique_name: $1)

    # 複数回マッチ用
    #re = /@[0-9a-zA-Z_]#{unique_name_length_range}/ # /@[0-9a-zA-Z_]{1,15}/
    #if unique_name = @micropost.content.scan(re).first
    #  unique_name.sub!("@","")
    #end
    #reply_user = User.find_by(unique_name: unique_name)

    @micropost.in_reply_to = reply_user.id if reply_user

    # マイクロポストを保存する。
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
