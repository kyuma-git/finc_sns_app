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

  resources :users
  resources :posts
  resources :comments

end
