Rails.application.routes.draw do

  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    passwords:     'users/passwords',
    registrations: 'users/registrations',
    sessions:      'users/sessions'
  }

  root :to => 'posts#index'

  get 'users/show'
  get 'users/new'

  resources :users do
    member do
    #フォロワー一覧のパス（余裕があったら追加する）
    #  get :following, :followers
    end
  end

  resources :posts
  resources :comments
  resources :relationships, only: [:create, :destroy]

end
