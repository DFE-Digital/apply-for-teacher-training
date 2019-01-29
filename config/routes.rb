Rails.application.routes.draw do
  devise_for :candidates
  devise_for :candidates, controllers: {
    registrations: 'candidates/registrations'
  }

  root to: 'home#index'

  namespace :admin do
    devise_for :users, class_name: 'Admin::User', controllers: { sessions: 'devise/sessions' }

    root to: 'home#index'

    resources :candidates, only: [:index, :show]
  end
end
