Rails.application.routes.draw do
  root to: 'start_page#show'

  get 'personal_details', to: 'personal_details#new'
  post 'personal_details', to: 'personal_details#create'
end
