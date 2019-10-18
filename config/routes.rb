Rails.application.routes.draw do
  # No Devise modules are enabled
  # Custom Warden strategy is used instead see app/warden/magic_link_token.rb
  # Custom views are used, see app/views/magic_link/sign_up/
  devise_for :candidates, skip: :all

  devise_scope :candidate do
    get '/candidate/sign-out', to: 'devise/sessions#destroy', as: :candidate_interface_sign_out
  end

  root to: redirect('/candidate')

  get '/accessibility', to: 'accessibility#show'

  namespace :candidate_interface, path: '/candidate' do
    get '/' => 'start_page#show', as: :start
    get '/sign-up', to: 'sign_up#new', as: :sign_up
    post '/sign-up', to: 'sign_up#create'

    get '/sign-in', to: 'sign_in#new', as: :sign_in
    post '/sign-in', to: 'sign_in#create'

    get '/apply', to: 'applying#show'

    scope '/application' do
      get '/' => 'application_form#show', as: :application_form
      get '/review' => 'application_form#review', as: :application_review
      get '/submit' => 'application_form#submit_show', as: :application_submit_show
      post '/submit' => 'application_form#submit', as: :application_submit
      get '/submit-success' => 'application_form#submit_success', as: :application_submit_success

      scope '/personal-details' do
        get '/' => 'personal_details#edit', as: :personal_details_edit
        post '/review' => 'personal_details#update', as: :personal_details_update
        get '/review' => 'personal_details#show', as: :personal_details_show
      end
    end
  end

  namespace :vendor_api, path: 'api/v1' do
    get '/applications' => 'applications#index'
    get '/applications/:application_id' => 'applications#show'

    post '/applications/:application_id/offer' => 'decisions#make_offer'
    post '/applications/:application_id/confirm-conditions-met' => 'decisions#confirm_conditions_met'
    post 'applications/:application_id/reject' => 'decisions#reject'
    post '/applications/:application_id/confirm-enrolment' => 'decisions#confirm_enrolment'

    post '/test-data/regenerate' => 'test_data#regenerate'

    get '/ping', to: 'ping#ping'
  end

  namespace :provider_interface, path: '/provider' do
    get '/' => redirect('/provider/applications')

    get '/applications' => 'application_choices#index'
    get '/applications/:application_choice_id' => 'application_choices#show', as: :application_choice
  end

  namespace :support_interface, path: '/support' do
    get '/' => redirect('/support/applications')

    get '/applications' => 'application_forms#index'
    get '/applications/:application_form_id' => 'application_forms#show', as: :application_form

    get '/tokens' => 'api_tokens#index', as: :api_tokens
    post '/tokens' => 'api_tokens#create'
  end

  get '/404', to: 'errors#not_found'
  get '/500', to: 'errors#internal_server_error'
  get '*path', to: 'errors#not_found'
end
