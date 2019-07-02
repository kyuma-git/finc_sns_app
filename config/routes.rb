# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api, { format: 'json' } do
    get "fetch_a_page_of_posts", to: "fetch_posts#fetch_a_page_of_posts"
    get "get_new_post", to: "get_new_post#get_new_post"
    get "get_post_image_url", to: "get_new_post#get_post_image_url"
  end
  
  namespace :admin do
    root to: 'index#index'
    resources :index, only: %i[index show]
  end
  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  root to: 'posts#index'

  resources :users do
    member do
      # フォロワー一覧のパス（余裕があったら追加する）
      #  get :following, :followers
    end
  end

  resources :posts do
    resources :post_likes, only: %i[create destroy]
    resources :comments do
      resources :comment_likes, only: %i[create destroy]
    end
  end
  resources :relationships, only: %i[create destroy]
end
