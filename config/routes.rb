# frozen_string_literal: true

Rails.application.routes.draw do
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
    resources :post_likes, only: [:create, :destroy]
    resources :comments do
      resources :comment_likes, only: [:create, :destroy]
    end
  end
  resources :relationships, only: [:create,  :destroy]
  # resources :post_likes, only: [:create, :destroy]
  # resources :comment_likes, only: [:create, :destroy]
end
