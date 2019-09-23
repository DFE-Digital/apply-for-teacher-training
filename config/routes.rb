Rails.application.routes.draw do
  # No Devise modules are enabled
  # Custom Warden strategy is used instead see app/warden/magic_link_token.rb
  # Custom views are used, see app/views/magic_link/sign_up/
  devise_for :candidates, skip: :all

  root to: 'start_page#show'

  get 'welcome', to: 'welcome#show'

  get 'sign-up', to: 'magic_link/sign_up#new', as: :new_sign_up
  post 'sign-up', to: 'magic_link/sign_up#create', as: :sign_up

  get 'check-your-answers', to: 'check_your_answers#show'
end
