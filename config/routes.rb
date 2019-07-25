Rails.application.routes.draw do
  root to: 'start_page#show'

  resources :personal_details, only: %i[new create edit update]

  resources :contact_details, only: %i[new create edit update]

  resources :degrees, only: %i[new create edit update]

  get 'check_your_answers', to: 'check_your_answers#show'

  get 'application', to: 'tt_applications#show', as: :tt_application
end
