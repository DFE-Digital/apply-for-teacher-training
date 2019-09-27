Rails.application.routes.draw do
  # No Devise modules are enabled
  # Custom Warden strategy is used instead see app/warden/magic_link_token.rb
  # Custom views are used, see app/views/magic_link/sign_up/
  devise_for :candidates, skip: :all

  devise_scope :candidate do
    get '/candidate/sign-out', to: 'devise/sessions#destroy', as: :candidate_interface_sign_out
  end

  root to: redirect('/candidate')

  namespace :candidate_interface, path: '/candidate' do
    get '/' => 'start_page#show', as: :start
    get '/welcome', to: 'welcome#show'
    get '/sign-up', to: 'sign_up#new', as: :sign_up
    post '/sign-up', to: 'sign_up#create'

    get '/sign-in', to: 'sign_in#new', as: :sign_in
    post '/sign-in', to: 'sign_in#create'
  end

  namespace :vendor_api, path: 'api/v1' do
    get '/ping', to: 'ping#ping'
  end

  namespace :provider, path: '/provider' do
    get '/' => 'home#index'
  end

  get ':actor/applications', constraints: { actor: /candidate|provider|referee/ }, controller: 'candidate_applications', action: :index, as: :tt_applications
  post 'candidate/applications', controller: 'candidate_applications', action: :create, as: :create_tt_application
  get ':actor/applications/clear', constraints: { actor: /candidate|provider|referee/ }, controller: 'candidate_applications', action: :destroy, as: :delete_all_tt_applications
  post ':actor/applications/:id', constraints: { actor: /candidate|provider|referee/ }, controller: 'candidate_applications', action: :update, as: :tt_application_update
end
