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
    CandidateInterface.new(self).routes
  end

  namespace :referee_interface, path: '/reference' do
    RefereeInterface.new(self).routes
  end

  namespace :vendor_api, path: 'api/v1' do
    VendorApiRoutes.new(self).routes
  end

  namespace :provider_interface, path: '/provider' do
    ProviderInterfaceRoutes.new(self).routes
  end

  get '/auth/dfe/callback' => 'dfe_sign_in#callback'
  post '/auth/developer/callback' => 'dfe_sign_in#bypass_callback'

  namespace :integrations, path: '/integrations' do
    IntegrationsRoutes.new(self).routes
  end

  namespace :support_interface, path: '/support' do
    SupportInterfaceRoutes.new(self).routes
  end

  namespace :api_docs, path: '/api-docs' do
    ApiDocsRoutes.new(self).routes
  end

  get '/check', to: 'healthcheck#show'

  scope via: :all do
    match '/404', to: 'errors#not_found'
    match '/406', to: 'errors#not_acceptable'
    match '/422', to: 'errors#unprocessable_entity'
    match '/500', to: 'errors#internal_server_error'
  end

  get '*path', to: 'errors#not_found'
end
