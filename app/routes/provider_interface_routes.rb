class ProviderInterfaceRoutes < RouteExtension
  def routes
    get '/' => 'start_page#show'

    get '/accessibility', to: 'content#accessibility'
    get '/privacy-policy', to: 'content#privacy_policy', as: :privacy_policy
    get '/cookies', to: 'content#cookies_provider', as: :cookies
    get '/terms-of-use', to: 'content#terms_provider', as: :terms

    get '/data-sharing-agreements/new', to: 'provider_agreements#new_data_sharing_agreement', as: :new_data_sharing_agreement
    post '/data-sharing-agreements', to: 'provider_agreements#create_data_sharing_agreement', as: :create_data_sharing_agreement
    get '/data-sharing-agreements/:id', to: 'provider_agreements#show_data_sharing_agreement', as: :show_data_sharing_agreement

    get '/applications' => 'application_choices#index'
    get '/applications/:application_choice_id' => 'application_choices#show', as: :application_choice
    get '/applications/:application_choice_id/respond' => 'decisions#respond', as: :application_choice_respond
    post '/applications/:application_choice_id/respond' => 'decisions#submit_response', as: :application_choice_submit_response
    get '/applications/:application_choice_id/offer' => 'decisions#new_offer', as: :application_choice_new_offer
    get '/applications/:application_choice_id/reject' => 'decisions#new_reject', as: :application_choice_new_reject
    post '/applications/:application_choice_id/reject/confirm' => 'decisions#confirm_reject', as: :application_choice_confirm_reject
    post '/applications/:application_choice_id/reject' => 'decisions#create_reject', as: :application_choice_create_reject
    post '/applications/:application_choice_id/offer/confirm' => 'decisions#confirm_offer', as: :application_choice_confirm_offer
    post '/applications/:application_choice_id/offer' => 'decisions#create_offer', as: :application_choice_create_offer

    get '/sign-in' => 'sessions#new'
    get '/sign-out' => 'sessions#destroy'
  end
end
