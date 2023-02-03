namespace :vendor_api, path: 'api/:api_version', api_version: /v[.0-9]+/, constraints: ValidVendorApiRoute do
  get '/applications' => 'applications#index'
  get '/applications/:application_id' => 'applications#show'

  post '/reference/:id/success' => 'references#success'
  post '/reference/:id/failure' => 'references#failure'

  scope path: '/applications/:application_id' do
    post '/offer' => 'decisions#make_offer'
    post '/confirm-conditions-met' => 'decisions#confirm_conditions_met'
    post '/conditions-not-met' => 'decisions#conditions_not_met'
    post '/reject' => 'decisions#reject'
    post '/reject-by-codes' => 'decisions#reject_by_codes'
    post '/confirm-enrolment' => 'decisions#confirm_enrolment'
    post '/notes/create' => 'notes#create'
    post '/withdraw' => 'withdraw_or_decline_offer#create'

    resource :deferred_offer, only: :create, path: 'defer-offer'
    resource :confirm_deferred_offer, only: :create, path: 'confirm-deferred-offer'

    post '/interviews/create' => 'interviews#create', as: :interviews_create
    post '/interviews/:interview_id/update' => 'interviews#update', as: :interviews_update
    post '/interviews/:interview_id/cancel' => 'interviews#cancel', as: :interviews_cancel
  end

  post '/test-data/regenerate' => 'test_data#regenerate'
  post '/test-data/generate' => 'test_data#generate'
  post '/test-data/clear' => 'test_data#clear!'

  get '/reference-data/gcse-subjects' => 'reference_data#gcse_subjects'
  get '/reference-data/gcse-grades' => 'reference_data#gcse_grades'
  get '/reference-data/a-and-as-level-subjects' => 'reference_data#a_and_as_level_subjects'
  get '/reference-data/a-and-as-level-grades' => 'reference_data#a_and_as_level_grades'
  get '/reference-data/rejection-reason-codes' => 'reference_data#rejection_reason_codes'

  post '/experimental/test-data/generate' => 'test_data#experimental_endpoint_moved'
  post '/experimental/test-data/clear' => 'test_data#experimental_endpoint_moved'

  get '/ping', to: 'ping#ping'
end
