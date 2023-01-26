namespace :register_api, path: 'register-api' do
  get '/applications' => 'applications#index'
end
