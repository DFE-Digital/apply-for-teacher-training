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

    resources :candidates, only: %i[index show]
  end

  namespace :api do
    scope module: 'v1' do
      resources :applications, only: %i[index show] do
        member do
          patch :make_offer
          patch :reject
        end
      end
    end

    namespace :v2 do
      resources :applications, only: %i[index show] do
        resources :decisions, only: [:index]
      end
    end
  end

  match '/404', to: 'errors#not_found', via: :all
  match '/403', to: 'errors#forbidden', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
  match '*path', to: 'errors#not_found', via: :all
end
