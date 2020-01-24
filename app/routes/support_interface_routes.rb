class SupportInterfaceRoutes < RouteExtension
  def routes
    get '/' => redirect('/support/candidates')

    get '/applications' => 'application_forms#index'
    get '/applications/:application_form_id' => 'application_forms#show', as: :application_form
    get '/applications/:application_form_id/audit' => 'application_forms#audit', as: :application_form_audit
    get '/applications/:application_form_id/comments/new' => 'application_forms/comments#new', as: :application_form_new_comment
    post '/applications/:application_form_id/comments' => 'application_forms/comments#create', as: :application_form_comments

    get '/send-email/:reference_id' => 'send_reference_email#new', as: :send_reference_email
    post '/send-email/:reference_id' => 'send_reference_email#create'

    get '/send-new-referee-request-email/:reference_id/:reason' => 'new_referee_request#show', as: :new_referee_request
    post '/send-new-referee-request-email/:reference_id/:reason' => 'new_referee_request#deliver'

    get '/candidates' => 'candidates#index'
    get '/candidates/:candidate_id' => 'candidates#show', as: :candidate
    post '/candidates/:candidate_id/hide' => 'candidates#hide_in_reporting', as: :hide_candidate
    post '/candidates/:candidate_id/show' => 'candidates#show_in_reporting', as: :show_candidate
    post '/candidates/:candidate_id/impersonate' => 'candidates#impersonate', as: :impersonate_candidate

    get '/chase-reference/:reference_id' => 'chase_reference#show', as: :chase_reference
    post '/chase-reference/:reference_id' => 'chase_reference#chase'

    get '/send-survey-email/:application_form_id' => 'survey_emails#show', as: :survey_emails
    post '/send-survey-email/:application_form_id' => 'survey_emails#deliver'

    get '/tokens' => 'api_tokens#index', as: :api_tokens
    post '/tokens' => 'api_tokens#create'

    get '/providers' => 'providers#index', as: :providers
    post '/providers/sync' => 'providers#sync'
    get '/providers/:provider_id' => 'providers#show', as: :provider
    post '/providers/:provider_id' => 'providers#open_all_courses'
    post '/providers/:provider_id/enable_course_syncing' => 'providers#enable_course_syncing', as: :enable_provider_course_syncing

    get '/courses/:course_id' => 'courses#show', as: :course
    post '/courses/:course_id' => 'courses#update'

    get '/feature-flags' => 'feature_flags#index', as: :feature_flags
    post '/feature-flags/:feature_name/activate' => 'feature_flags#activate', as: :activate_feature_flag
    post '/feature-flags/:feature_name/deactivate' => 'feature_flags#deactivate', as: :deactivate_feature_flag

    get '/performance' => 'performance#index', as: :performance

    get '/tasks' => 'tasks#index', as: :tasks
    post '/tasks/:task' => 'tasks#run', as: :run_task

    scope '/users' do
      get '/' => 'users#index', as: :users

      resources :support_users, only: %i[index new create], path: :support
      resources :provider_users, only: %i[index new create edit update], path: :provider
    end

    get '/sign-in' => 'sessions#new'
    get '/sign-out' => 'sessions#destroy'

    # https://github.com/mperham/sidekiq/wiki/Monitoring#rails-http-basic-auth-from-routes
    require 'sidekiq/web'
    require 'support_user_constraint'

    mount Sidekiq::Web => '/sidekiq', constraints: SupportUserConstraint.new
    get '/sidekiq', to: redirect('/support/sign-in'), status: 302
  end
end
