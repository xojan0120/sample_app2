Rails.application.routes.draw do

  get 'password_resets/new'

  get 'password_resets/edit'

  root                    'static_pages#home'
  get     '/home',    to: 'static_pages#home'
  get     '/help',    to: 'static_pages#help'
  get     '/about',   to: 'static_pages#about'
  get     '/contact', to: 'static_pages#contact'
  get     '/signup',  to: 'users#new'
  post    '/signup',  to: 'users#create'
  get     '/login',   to: 'sessions#new'
  post    '/login',   to: 'sessions#create'
  delete  '/logout',  to: 'sessions#destroy'

  # resourcesは主要な7つ(index,create,new,edit,show,update,destroy)のルーティングが自動追加されるが、
  # それ意外のルーティングを、そのリソースに追加したい場合にmemberまたはcollectionを使用する。
  # memberはid有り、collectionはid無しの違いがある。
  # 参考：https://techracho.bpsinc.jp/baba/2014_03_03/15619
  resources :users do
    member do # memberはメソッド
      # following_user GET    /users/:id/following(.:format)          users#following
      # followers_user GET    /users/:id/followers(.:format)          users#followers
      # 下記で上記２つが追加される。memberなので:idがつく。collectionだと/users/following(.:format)のようになる。
      get :following, :followers
    end
  end
  
  resources :users
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :microposts,          only: [:create, :destroy]
  resources :relationships,       only: [:create, :destroy]

end
