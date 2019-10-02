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

    get '/apply', to: 'applying#show'
  end

  namespace :vendor_api, path: 'api/v1' do
    get '/applications' => 'applications#index'
    get '/applications/:application_id' => 'applications#show'
    post '/applications/:application_id/offer' => 'offers#create'

    post 'applications/:application_id/confirm-enrolment' => 'confirm_candidate_enrolment#confirm'

    post '/test-data/regenerate' => 'test_data#regenerate'

    get '/ping', to: 'ping#ping'
  end

  namespace :provider, path: '/provider' do
    get '/' => 'home#index'
  end
end
