Rails.application.routes.draw do
  root :to => "posts#index"
  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    passwords:     'users/passwords',
    registrations: 'users/registrations',
    sessions:      'users/sessions'
  }
  resources :users
  resources :posts
  resources :comments
end
