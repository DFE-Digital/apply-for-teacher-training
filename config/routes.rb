Rails.application.routes.draw do
  root to: 'home#index'


  namespace :admin do
    devise_for :users, class_name: 'Admin::User', controllers: { sessions: 'devise/sessions' }

    root to: 'home#index'
  end
end
