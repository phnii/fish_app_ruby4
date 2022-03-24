Rails.application.routes.draw do
  devise_for :users
  root to: 'trips#index'
  resources :users, only: :show do
    member do
      get 'follow_list'
    end
  end
  
  resources :trips do
    collection do
      get 'search'
    end
    resources :comments, only: [:create, :destroy]
  end

  resources :relationships, only: [:create, :destroy]
  
  resources :rooms, only: :create do
    resources :messages, only: [:index, :create]
  end
end
