Rails.application.routes.draw do
  # No Devise modules are enabled
  # Custom Warden strategy is used instead see app/warden/magic_link_token.rb
  # Custom views are used, see app/views/magic_link/sign_up/
  devise_for :candidates, skip: :all

  root to: 'start_page#show'

  resources :personal_details, only: %i[new create edit update], path: 'personal-details'
  resources :contact_details, only: %i[new create edit update], path: 'contact-details'
  resources :degrees, only: %i[new create edit update]
  resources :qualifications, only: %i[new create edit update]

  get 'sign-up', to: 'magic_link/sign_up#new', as: :new_sign_up
  post 'sign-up', to: 'magic_link/sign_up#create', as: :sign_up

  get 'check-your-answers', to: 'check_your_answers#show'
  get 'application', to: 'tt_applications#show', as: :tt_application
  post 'application/submit', to: 'tt_application_submissions#create', as: :tt_application_submission
end
