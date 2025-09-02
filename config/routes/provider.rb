namespace :provider_interface, path: '/provider' do
  get '/' => 'start_page#show'

  get '/accessibility', to: 'content#accessibility'
  get '/privacy-policy', to: redirect('provider/privacy')
  get '/privacy', to: 'content#privacy', as: :privacy
  get '/privacy/service-privacy-notice', to: 'content#service_privacy_notice', as: :service_privacy_notice
  get '/privacy/online-chat-privacy-notice', to: 'content#online_chat_privacy_notice', as: :online_chat_privacy_notice
  get '/cookies', to: 'content#cookies_page', as: :cookies
  get '/roadmap', to: 'content#roadmap', as: :roadmap
  get '/service-guidance', to: 'content#service_guidance_provider', as: :service_guidance
  get '/service-guidance/dates-and-deadlines', to: 'content#dates_and_deadlines'
  get '/covid-19-guidance', to: redirect('/')
  get '/organisation-permissions-guidance', to: 'content#organisation_permissions'
  get '/guidance-for-using-ai', to: 'content#guidance_for_using_ai'

  resources :cookie_preferences, only: 'create', path: 'cookie-preferences'
  post '/cookie-preferences-hide-confirmation', to: 'cookie_preferences#hide_confirmation', as: :cookie_preferences_hide_confirmation

  get '/data-sharing-agreements/new', to: 'provider_agreements#new_data_sharing_agreement', as: :new_data_sharing_agreement
  post '/data-sharing-agreements', to: 'provider_agreements#create_data_sharing_agreement', as: :create_data_sharing_agreement
  get '/old-data-sharing-agreement', to: 'provider_agreements#old_data_sharing_agreement', as: :old_data_sharing_agreement

  get '/activity' => 'activity_log#index', as: :activity_log

  get '/applications' => 'application_choices#index'

  namespace :candidate_pool, path: 'find-candidates' do
    resources :not_seen, only: %i[index], path: 'not-seen'
    resources :invites, only: %i[index show], path: 'invited'
    resources :candidates, only: %i[index show], path: '/' do
      resource :shares, only: %i[show], path: 'share'
      resources :draft_invites, path: 'invite' do
        resource :provider_invite_messages, only: %i[new create edit update], path: 'message'
        resource :publish_invite, only: %i[create], path: 'review'
      end
    end

    root to: 'candidates#index'
  end

  resources :reports, only: :index

  resources :location_suggestions, only: :index, path: 'location-suggestions'

  namespace :reports do
    resources :hesa_exports, only: :show, path: 'hesa-exports', param: :year, constraints: ValidRecruitmentCycleYear
    resources :hesa_exports, only: :index, path: 'hesa-exports'
    resources :withdrawal_reports, only: :index, path: 'withdrawal-reports'
    resources :providers, only: [], path: '' do
      resource :status_of_active_applications, only: :show, path: 'status-of-active-applications'
      resource :diversity_report, only: :show, path: 'diversity-report'
      resource :withdrawal_report, only: :show, path: 'withdrawal-report'
      resource :withdrawal_reasons_report, only: :show, path: 'withdrawal-reasons-report'
      resource :recruitment_performance_report, only: :show, path: 'recruitment-performance-report'
    end
  end

  get '/applications/hesa-export/new', to: redirect('provider/reports/hesa-exports')
  get '/applications/hesa-export', to: redirect('provider/reports/hesa-exports')

  get 'applications/data-export/new' => 'application_data_export#new', as: :new_application_data_export
  get 'applications/data-export' => 'application_data_export#export', as: :application_data_export

  scope path: '/applications/:application_choice_id' do
    get '/' => 'application_choices#show', as: :application_choice
    get '/timeline' => 'application_choices#timeline', as: :application_choice_timeline
    get '/emails' => 'application_choices#emails', as: :application_choice_emails
    get '/feedback' => 'application_choices#feedback', as: :application_choice_feedback
    # TODO: Remove redirect after 1 Sept 2021
    get '/conditions', to: redirect('/provider/applications/%{application_choice_id}/condition-statuses/edit')

    resource :condition_statuses, only: %i[edit update], path: 'condition-statuses' do
      resource :check, only: %i[edit update], controller: 'condition_statuses/checks'
    end

    get '/offer/new_withdraw' => redirect('/offer/withdraw')
    post '/offer/confirm_withdraw' => redirect('/offer/confirm-withdraw')
    get '/offer/withdraw' => 'decisions#new_withdraw_offer', as: :application_choice_new_withdraw_offer
    post '/offer/confirm-withdraw' => 'decisions#confirm_withdraw_offer', as: :application_choice_confirm_withdraw_offer
    post '/offer/withdraw' => 'decisions#withdraw_offer', as: :application_choice_withdraw_offer

    get '/offer/defer' => 'decisions#new_defer_offer', as: :application_choice_new_defer_offer
    post '/offer/defer' => 'decisions#defer_offer', as: :application_choice_defer_offer

    namespace :deferred_offer, path: 'deferred-offer' do
      # Routes for the course selection step
      # get '/course', to: 'courses#edit'
      # post '/course', to: 'courses#update'

      # Routes for the location selection step
      # get '/location', to: 'location#edit'
      # post '/location', to: 'location#update'

      # Routes for the study mode selection step
      # get '/study-mode', to: 'study_mode#edit'
      # post '/study-mode', to: 'study_mode#update'

      # Routes for the check your answers step
      resource :check, only: :show

      # Routes for the conditions step
      get '/conditions', to: 'conditions#edit'
      post '/conditions', to: 'conditions#update'

      # Routes for the final submission to confirm the deferral
      # resource :confirm, only: :create, controller: :confirm
    end

    resource :decision, only: %i[new create], as: :application_choice_decision

    resource :offers, only: %i[new edit create show update], as: :application_choice_offer
    resource :offers, only: %i[new edit], as: :application_choice_offer_referer

    resource :courses, only: %i[update], as: :application_choice_course

    namespace :offer, as: :application_choice_offer do
      resource :providers, only: %i[new create edit update]
      resource :courses, only: %i[new create edit update]
      resource :study_modes, only: %i[new create edit update], path: 'study-modes'
      resource :locations, only: %i[new create edit update]
      resource :conditions, only: %i[new create edit update]
      resource :check, only: %i[new edit]
      resource :ske_requirements, only: %i[new create update edit], path: 'ske-requirements'
      resource :ske_reason, only: %i[new create update edit], path: 'ske-reason'
      resource :ske_length, only: %i[new create update edit], path: 'ske-length'
      resource :recruit_with_pending_conditions, only: %i[new create], path: 'recruit-with-pending-conditions'
    end

    namespace :courses, as: :application_choice_course do
      resource :providers, only: %i[edit update]
      resource :courses, only: %i[edit update]
      resource :study_modes, only: %i[edit update], path: 'study-modes'
      resource :locations, only: %i[edit update]
      resource :check, only: %i[edit update]
    end

    resources :rejections, only: %i[new create] do
      collection do
        get 'check'
        post 'commit'
      end
    end

    get '/decline-or-withdraw' => 'decline_or_withdraw#edit', as: :decline_or_withdraw_edit
    put '/decline-or-withdraw' => 'decline_or_withdraw#update', as: :decline_or_withdraw_update

    resources :references, only: %i[index], as: :application_choice_references
    resources :notes, only: %i[index show new create], as: :application_choice_notes

    resources :interviews, only: %i[new create update edit index destroy], as: :application_choice_interviews do
      resource :cancel, only: %i[new create show], controller: 'interviews/cancel'
      resource :check, only: %i[edit update], controller: 'interviews/checks'
    end

    namespace :interviews, as: :application_choice_interviews do
      resource :check, only: %i[new create]
    end
  end

  resource :interview_schedule, path: 'interview-schedule', only: :show do
    get :past, on: :collection
  end

  post '/candidates/:candidate_id/impersonate' => 'candidates#impersonate', as: :impersonate_candidate

  get '/sign-in' => 'sessions#new'
  get '/sign-out' => 'sessions#destroy'

  post '/request-sign-in-by-email' => 'sessions#sign_in_by_email', as: :sign_in_by_email
  get '/sign-in/check-email', to: 'sessions#check_your_email', as: :check_your_email
  get '/sign-in-by-email' => 'sessions#confirm_authentication_with_token', as: :confirm_authentication_with_token
  post '/sign-in-by-email' => 'sessions#authenticate_with_token', as: :authenticate_with_token
  post '/request-new-token' => 'sessions#request_new_token', as: :request_new_token

  get '/account' => 'account#show'

  scope path: '/account' do
    get '/profile', to: redirect('/provider/account/personal-details')

    resource :personal_details, only: :show, path: 'personal-details'

    get '/users', to: redirect('/provider/organisation-settings')

    resource :personal_permissions, only: %i[show], path: 'permissions'

    # TODO: Revisit whether these redirects are still needed after 1st November 2021
    get '/organisational-permissions', to: redirect('/provider/organisation-settings')
    get '/organisational-permissions/:id', to: redirect { |params, _| "/provider/organisation-settings/organisations/#{params[:id]}/organisation-permissions" }

    resource :notifications, only: %i[show update], path: 'notification-settings'
  end

  resource :organisation_settings, path: '/organisation-settings', only: :show do
    resources :organisations, only: [] do
      get '/', to: redirect('/provider/organisation-settings'), on: :collection
      resources :organisation_permissions, path: '/organisation-permissions', only: %i[index edit update]
      resources :users, path: '/users', only: %i[index show destroy] do
        member do
          get :confirm_destroy, path: 'delete'

          resource :user_permissions, path: 'permissions', only: %i[edit update] do
            member do
              get :check
              put :commit
            end
          end
        end
      end

      resources :api_tokens, path: 'api-tokens', only: %i[index new create]

      namespace :user_invitation, path: 'user' do
        resource :personal_details, path: '', only: %i[new create]
        resource :permissions, only: %i[new create]
        get 'check' => 'review#check', as: :check
        post 'commit' => 'review#commit', as: :commit
      end
    end
  end

  scope path: 'setup' do
    resources :organisation_permissions_setup, only: %i[index edit update], path: 'organisation-permissions' do
      collection do
        get :check
        post :commit
        get :success
      end
    end
  end

  scope path: '/applications/:application_choice_id/offer/reconfirm' do
    get '/' => 'reconfirm_deferred_offers#new', as: :reconfirm_deferred_offer
    get '/conditions' => 'reconfirm_deferred_offers#conditions', as: :reconfirm_deferred_offer_conditions
    patch '/conditions' => 'reconfirm_deferred_offers#update_conditions'
    get '/check' => 'reconfirm_deferred_offers#check', as: :reconfirm_deferred_offer_check
    post '/' => 'reconfirm_deferred_offers#commit'
  end

  get '*path', to: 'errors#not_found'
end
