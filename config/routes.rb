Rails.application.routes.draw do
  devise_for :candidates, controllers: {
    registrations: 'candidates/registrations'
  }

  authenticated :candidate do
    root 'home#index', as: :authenticated_root
  end

  unauthenticated :candidate do
    root 'home#landing', as: :unauthenticated_root
  end

  root to: 'home#index'

  get 'profile', action: :show, controller: 'profile'
  get 'profile/edit', action: :edit, controller: 'profile'
  put 'profile', action: :update, controller: 'profile'
  patch 'profile', action: :update, controller: 'profile'

  namespace :admin do
    devise_for :users, class_name: 'Admin::User', controllers: { sessions: 'devise/sessions' }

    authenticated :user do
      root 'home#index', as: :authenticated_root
    end

    root to: 'home#index'

    resources :candidates, only: [:index, :show]
  end
end
