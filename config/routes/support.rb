namespace :support_interface, path: '/support' do
  get '/' => redirect('/support/applications')
  root to: 'application_forms#index'

  get '/applications' => 'application_forms#index'

  scope path: '/applications/:application_form_id' do
    get '/' => 'application_forms#show', as: :application_form

    get '/change-course-choice/:application_choice_id' => 'application_forms/courses#edit', as: :application_form_change_course_choice
    post '/change-course-choice/:application_choice_id' => 'application_forms/courses#update'

    get '/editable-extension' => 'application_forms/editable_extension#edit'
    post '/editable-extension' => 'application_forms/editable_extension#update'

    get '/email-subscription' => 'application_forms/email_subscription#edit'
    patch '/email-subscription' => 'application_forms/email_subscription#update'

    get '/audit' => 'application_forms#audit', as: :application_form_audit
    get '/comments/new' => 'application_forms/comments#new', as: :application_form_new_comment
    post '/comments' => 'application_forms/comments#create', as: :application_form_comments

    get '/applicant-details' => 'application_forms/applicant_details#edit', as: :application_form_edit_applicant_details
    post '/applicant-details' => 'application_forms/applicant_details#update', as: :application_form_update_applicant_details

    get '/gcses/:id/edit' => 'application_forms/gcses#edit', as: :application_form_edit_gcse
    post '/gcses/:id' => 'application_forms/gcses#update', as: :application_form_update_gcse

    get '/other-qualification/:id' => 'application_forms/other_qualifications#edit', as: :application_form_edit_other_qualification
    patch '/other-qualification/:id' => 'application_forms/other_qualifications#update', as: :application_form_update_other_qualification

    get '/degrees/:degree_id' => 'application_forms/degrees#edit', as: :application_form_edit_degree
    post '/degrees/:degree_id' => 'application_forms/degrees#update', as: :application_form_update_degree

    get '/references/:reference_id/details' => 'application_forms/references#edit_reference_details', as: :application_form_edit_reference_details
    post '/references/:reference_id/details' => 'application_forms/references#update_reference_details', as: :application_form_update_reference_details

    get '/references/:reference_id/feedback' => 'application_forms/references#edit_reference_feedback', as: :application_form_edit_reference_feedback
    post '/references/:reference_id/feedback' => 'application_forms/references#update_reference_feedback', as: :application_form_update_reference_feedback

    get '/becoming-a-teacher' => 'application_forms/personal_statement#edit_becoming_a_teacher', as: :application_form_edit_becoming_a_teacher
    patch '/becoming-a-teacher' => 'application_forms/personal_statement#update_becoming_a_teacher'

    get '/applicant-address-type' => 'application_forms/address_type#edit', as: :application_form_edit_address_type
    post '/applicant-address-type' => 'application_forms/address_type#update', as: :application_form_update_address_type
    get '/applicant-address-details' => 'application_forms/address_details#edit', as: :application_form_edit_address_details
    post '/applicant-address-details' => 'application_forms/address_details#update', as: :application_form_update_address_details

    get '/nationalities' => 'application_forms/nationalities#edit', as: :application_form_edit_nationalities
    patch '/nationalities' => 'application_forms/nationalities#update'
    get '/right-to-work-or-study' => 'application_forms/immigration_right_to_work#edit', as: :application_form_edit_immigration_right_to_work
    patch '/right-to-work-or-study' => 'application_forms/immigration_right_to_work#update'

    get '/immigration-status' => 'application_forms/immigration_status#edit', as: :application_form_edit_immigration_status
    patch '/immigration-status' => 'application_forms/immigration_status#update'

    get '/reinstate-offer/:application_choice_id' => 'application_forms/application_choices/reinstate_declined_offer#confirm_reinstate_offer', as: :application_form_application_choice_reinstate_offer
    patch '/reinstate-offer/:application_choice_id' => 'application_forms/application_choices/reinstate_declined_offer#reinstate_offer'

    get '/change-offered-course-search/:application_choice_id' => 'application_forms/application_choices/change_offered_course#change_offered_course_search', as: :application_form_application_choice_change_offered_course_search
    post '/change-offered-course-search/:application_choice_id' => 'application_forms/application_choices/change_offered_course#search'

    get '/choose-offered-course/:application_choice_id' => 'application_forms/application_choices/change_offered_course#offered_course_options', as: :application_form_application_choice_choose_offered_course_option
    post '/choose-offered-course/:application_choice_id' => 'application_forms/application_choices/change_offered_course#choose_offered_course_option'

    get '/confirm-offered-course/:application_choice_id/:application_choice_id' => 'application_forms/application_choices/change_offered_course#confirm_offered_course_option', as: :application_form_application_choice_confirm_offered_course_option
    patch '/confirm-offered-course/:application_choice_id/:application_choice_id' => 'application_forms/application_choices/change_offered_course#update_offered_course_option'

    get '/revert-rejection/:application_choice_id' => 'application_forms/application_choices#confirm_revert_rejection', as: :application_form_revert_rejection
    patch '/revert-rejection/:application_choice_id' => 'application_forms/application_choices#revert_rejection'

    get '/revert-withdrawal/:application_choice_id' => 'application_forms/application_choices#confirm_revert_withdrawal', as: :application_form_application_choice_revert_withdrawal
    patch '/revert-withdrawal/:application_choice_id' => 'application_forms/application_choices#revert_withdrawal'

    get '/revert-to-pending-conditions/:application_choice_id' => 'application_forms/application_choices#confirm_revert_to_pending_conditions', as: :application_form_application_choice_revert_to_pending_conditions
    patch '/revert-to-pending-conditions/:application_choice_id' => 'application_forms/application_choices#revert_to_pending_conditions'

    get '/confirm-delete-application' => 'application_forms/delete_application#confirm_delete', as: :confirm_delete_application_form
    delete '/delete-application' => 'application_forms/delete_application#delete', as: :delete_application_form

    scope '/work-history' do
      get 'jobs/:job_id' => 'application_forms/jobs#edit', as: :application_form_edit_job
      post 'jobs/:job_id' => 'application_forms/jobs#update', as: :application_form_update_job

      get 'volunteering-roles/:volunteering_role_id' => 'application_forms/volunteering_roles#edit', as: :application_form_edit_volunteering_role
      post 'volunteering-roles/:volunteering_role_id' => 'application_forms/volunteering_roles#update', as: :application_form_update_volunteering_role
    end

    resource :one_login_auths, only: %i[edit update], path: '/one-login-auths'
  end

  get '/duplicate-matches' => 'duplicate_matches#index', as: :duplicate_matches
  get '/duplicate-matches/:id' => 'duplicate_matches#show', as: :duplicate_match
  patch '/duplicate-matches/:id' => 'duplicate_matches#update', as: :update_duplicate_match

  get '/application_choices/:application_choice_id' => redirect('/application-choices/%{application_choice_id}')
  get '/application-choices/:application_choice_id' => 'application_choices#show', as: :application_choice
  get '/application-choices/:application_choice_id/conditions' => 'application_choice_conditions#edit', as: :edit_application_choice_conditions
  put '/application-choices/:application_choice_id/conditions' => 'application_choice_conditions#update', as: :update_application_choice_conditions
  get '/application-choices/:application_choice_id/make-unconditional' => 'application_choice_conditions#confirm_make_unconditional', as: :confirm_make_application_choice_unconditional
  put '/application-choices/:application_choice_id/make-unconditional' => 'application_choice_conditions#make_unconditional', as: :make_application_choice_unconditional

  resources :application_forms, only: [], path: 'application-forms' do
    resource :course_recommendation, path: 'course-recommendation', only: %i[show], module: :application_forms
  end

  resources :application_choices, only: [], path: 'application-choices' do
    resource :course_recommendation, path: 'course-recommendation', only: %i[show], module: :application_choices
  end

  get '/candidates' => 'candidates#index'

  resources :location_suggestions, only: :index, path: 'location-suggestions'

  scope path: '/candidates' do
    resource :bulk_unsubscribe, only: %i[new create], path: '/bulk-unsubscribe', module: :candidates
  end

  scope path: '/candidates/:candidate_id' do
    get '/' => 'candidates#show', as: :candidate
    post '/hide' => 'candidates#hide_in_reporting', as: :hide_candidate
    post '/show' => 'candidates#show_in_reporting', as: :show_candidate
    post '/impersonate' => 'candidates#impersonate', as: :impersonate_candidate
    get '/status' => 'candidates#edit_candidate_account_status', as: :edit_candidate_account_status
    patch '/status' => 'candidates#update_candidate_account_status', as: :update_candidate_account_status
  end

  scope path: '/references/:reference_id' do
    get '/cancel' => 'references#cancel', as: :cancel_reference
    post '/cancel' => 'references#confirm_cancel'
    get '/reinstate' => 'references#reinstate', as: :reinstate_reference
    post '/reinstate' => 'references#confirm_reinstate'
    get '/destroy' => 'references#destroy', as: :destroy_reference
    post '/destroy' => 'references#confirm_destroy'
    get '/impersonate-and-give' => 'references#impersonate_and_give', as: :impersonate_referee_and_give_reference
    get 'impersonate-and-decline' => 'references#impersonate_and_decline', as: :impersonate_referee_and_decline_reference
  end

  resources :api_tokens, path: '/tokens', only: %i[index new create destroy] do
    member do
      get 'confirm-revocation'
    end
  end

  get '/providers' => 'providers#index', as: :providers

  scope path: '/providers/users/:provider_user_id' do
    get '/permissions/edit' => 'single_provider_users#edit', as: :edit_permissions
    patch '/permissions' => 'single_provider_users#update', as: :update_permissions
    get '/notifications/edit' => 'single_provider_user_notifications#edit', as: :edit_provider_notifications
    put '/notifications' => 'single_provider_user_notifications#update', as: :update_provider_notifications
    get '/permissions/:provider_permissions_id/remove' => 'single_provider_user_removals#new', as: :provider_user_removals
    delete '/permissions/:provider_permissions_id/remove' => 'single_provider_user_removals#create', as: :remove_provider_user
  end

  scope path: '/providers/:provider_id' do
    get '/' => 'providers#show', as: :provider
    get '/courses' => 'providers#courses', as: :provider_courses
    get '/ratified-courses' => 'providers#ratified_courses', as: :provider_ratified_courses
    get '/courses-csv' => 'providers#courses_as_csv', as: :provider_courses_csv
    get '/vacancies' => 'providers#vacancies', as: :provider_vacancies
    get '/sites' => 'providers#sites', as: :provider_sites
    get '/users' => 'providers#users', as: :provider_user_list
    get '/applications' => 'providers#applications', as: :provider_applications
    get '/history' => 'providers#history', as: :provider_history
    get '/relationships' => 'providers#relationships', as: :provider_relationships
    post '/relationships' => 'providers#update_relationships', as: :update_provider_relationships

    get '/user/new' => 'single_provider_users#new', as: :new_single_provider_user
    post '/user' => 'single_provider_users#create', as: :create_single_provider_user

    namespace :bulk_upload, path: '/bulk-upload' do
      resource :provider_users_details, path: '/provider-users-details', only: %i[new create]
      resource :permissions, only: %i[edit update]
      resource :checks, only: %i[show]
      resource :provider_users, path: '/provider-users', only: %i[create]
    end

    resource :provider_test_data, path: '/test-data', only: %i[create]
  end

  scope path: '/courses/:course_id' do
    get '/' => 'course#show', as: :course
    get '/applications' => 'course#applications', as: :course_applications
    get '/vacancies' => 'course#vacancies', as: :course_vacancies

    post '' => 'course#update'
  end

  scope '/performance' do
    get '/' => 'performance#index', as: :performance

    get '/course-statistics', to: 'performance#courses_dashboard', as: :courses_dashboard
    get '/reasons-for-rejection' => 'performance#reasons_for_rejection_dashboard', as: :reasons_for_rejection_dashboard
    get '/reasons-for-rejection/application-choices' => 'performance#reasons_for_rejection_application_choices', as: :reasons_for_rejection_application_choices
    get '/service' => 'performance#service_performance_dashboard', as: :service_performance_dashboard

    get '/course-options', to: 'performance#course_options', as: :course_options
    get '/unavailable-choices' => 'performance#unavailable_choices', as: :unavailable_choices
    get '/unavailable-choices/closed-courses' => 'performance#unavailable_choices_closed_courses', as: :unavailable_choices_closed_courses
    get '/unavailable-choices/hidden-courses' => 'performance#unavailable_choices_hidden_courses', as: :unavailable_choices_hidden_courses
    get '/unavailable-choices/removed-sites' => 'performance#unavailable_choices_removed_sites', as: :unavailable_choices_removed_sites
    get '/unavailable-choices/without-vacancies' => 'performance#unavailable_choices_without_vacancies', as: :unavailable_choices_without_vacancies

    get '/data-export/documentation/:export_type_id' => 'data_exports#data_set_documentation', as: :data_set_documentation
    get '/data-directory' => 'data_exports#directory', as: :data_directory
    get '/data-directory/export/:data_export_type' => 'data_exports#view_export_information', as: :view_export_information
    get '/data-directory/export-history' => 'data_exports#history', as: :data_exports_history
    get '/data-directory/export/:data_export_type/history' => 'data_exports#view_history', as: :view_history

    get '/monthly-statistics-reports' => 'monthly_statistics_reports#index', as: :monthly_statistics_reports
    get '/monthly-statistics-reports/:id' => 'monthly_statistics_reports#show', as: :monthly_statistics_report

    get '/validation-errors' => 'validation_errors#index', as: :validation_errors

    namespace :validation_errors, path: '/validation-errors' do
      scope '/candidate' do
        get '/' => 'candidate#index', as: :candidate
        get '/search' => 'candidate#search', as: :candidate_search
        get '/summary' => 'candidate#summary', as: :candidate_summary
      end

      scope '/provider' do
        get '/' => 'provider#index', as: :provider
        get '/search' => 'provider#search', as: :provider_search
        get '/summary' => 'provider#summary', as: :provider_summary
      end

      scope '/vendor-api' do
        get '/' => 'vendor_api#index', as: :vendor_api
        get '/search' => 'vendor_api#search', as: :vendor_api_search
        get '/summary' => 'vendor_api#summary', as: :vendor_api_summary
      end
    end

    resources :data_exports, path: '/data-exports' do
      member do
        get :download
      end
    end
  end

  get '/email-log', to: 'email_log#index', as: :email_log
  get '/provider-onboarding', to: 'provider_onboarding#index', as: :provider_onboarding
  get '/vendor-api-requests', to: 'vendor_api_requests#index', as: :vendor_api_requests
  get '/vendor-api-monitoring', to: 'vendor_api_monitoring#index', as: :vendor_api_monitoring

  scope '/settings' do
    get '/' => redirect('/support/settings/feature-flags'), as: :settings
    get '/feature-flags' => 'settings#feature_flags', as: :feature_flags
    post '/feature-flags/:feature_name/activate' => 'settings#activate_feature_flag', as: :activate_feature_flag
    post '/feature-flags/:feature_name/deactivate' => 'settings#deactivate_feature_flag', as: :deactivate_feature_flag

    get 'recruitment-cycle-timetable', to: 'recruitment_cycle_timetables#index', as: :recruitment_cycle_timetables
    unless HostingEnvironment.production?
      post '/recruitment-cycle-timetables/reset', to: 'recruitment_cycle_timetables#reset', as: :sync_cycle_with_production
      get '/recruitment-cycle-timetable/:recruitment_cycle_year', to: 'recruitment_cycle_timetables#edit', as: :edit_recruitment_cycle_timetable
      post '/recruitment-cycle-timetable/:recruitment_cycle_year', to: 'recruitment_cycle_timetables#update', as: :update_recruitment_cycle_timetable
    end

    get '/notify-template', to: 'settings#notify_template', as: :notify_template
    post '/send-notify-template', to: 'settings#send_notify_template', as: :send_notify_template

    get '/tasks' => 'tasks#index', as: :tasks
    post '/tasks/create-fake-provider' => 'tasks#create_fake_provider'
    post '/tasks/:task' => 'tasks#run', as: :run_task
    get '/tasks/confirm-delete-test-applications' => 'tasks#confirm_delete_test_applications', as: :confirm_delete_test_applications
    get '/tasks/confirm-cancel-applications-at-end-of-cycle' => 'tasks#confirm_cancel_applications_at_end_of_cycle', as: :confirm_cancel_applications_at_end_of_cycle
  end

  scope '/docs' do
    get '/', to: redirect('/support/docs/candidate-flow'), status: 302, as: :docs
    get '/candidate-flow', to: 'docs#candidate_flow', as: :docs_candidate_flow
    get '/provider-flow', to: 'docs#provider_flow', as: :docs_provider_flow
    get '/qualifications', to: 'docs#qualifications', as: :docs_qualifications
    get '/mailers' => 'docs#mailer_previews', as: :docs_mailer_previews
    get '/components' => 'docs#component_previews', as: :docs_component_previews
  end

  scope '/users' do
    get '/' => 'users#index', as: :users

    get '/delete/:id' => 'support_users#confirm_destroy', as: :confirm_destroy_support_user
    delete '/delete/:id' => 'support_users#destroy', as: :destroy_support_user
    get '/restore/:id' => 'support_users#confirm_restore', as: :confirm_restore_support_user
    delete '/restore/:id' => 'support_users#restore', as: :restore_support_user

    resources :support_users, only: %i[index new create show], path: :support

    get '/provider/end-impersonation' => 'provider_users#end_impersonation', as: :end_impersonation

    resources :personas, only: %i[index]

    resources :provider_users, only: %i[show index], path: :provider do
      get '/audits' => 'provider_users#audits'
      put '/update-notifications' => 'provider_user_notification_preferences#update_notifications', as: :update_notifications
      post '/impersonate' => 'provider_users#impersonate', as: :impersonate
    end
  end

  get '/sign-in' => 'sessions#new', as: :sign_in
  get '/sign-out' => 'sessions#destroy', as: :sign_out

  get '/confirm-environment' => 'sessions#confirm_environment', as: :confirm_environment
  post '/confirm-environment' => 'sessions#confirmed_environment'

  post '/request-sign-in-by-email' => 'sessions#sign_in_by_email', as: :sign_in_by_email

  get '/sign-in/check-email', to: 'sessions#check_your_email', as: :check_your_email
  get '/sign-in-by-email' => 'sessions#confirm_authentication_with_token', as: :confirm_authentication_with_token
  post '/sign-in-by-email' => 'sessions#authenticate_with_token', as: :authenticate_with_token
  post '/request-new-token' => 'sessions#request_new_token', as: :request_new_token

  require 'sidekiq/web'

  mount SupportInterface::RackApp.new(Sidekiq::Web) => '/sidekiq', as: :sidekiq
  mount SupportInterface::RackApp.new(Blazer::Engine) => '/blazer', as: :blazer
  mount SupportInterface::RackApp.new(FieldTest::Engine) => '/field-test', as: :field_test

  get '*path', to: 'errors#not_found'
end
