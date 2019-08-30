Rails.application.routes.draw do
  root to: 'start_page#show'

  resources :personal_details, only: %i[new create edit update], path: 'personal-details'
  resources :contact_details, only: %i[new create edit update], path: 'contact-details'
  resources :degrees, only: %i[new create edit update]
  resources :qualifications, only: %i[new create edit update]

  get 'check-your-answers', to: 'check_your_answers#show'
  get 'application', to: 'tt_applications#show', as: :tt_application
  post 'application/submit', to: 'tt_application_submissions#create', as: :tt_application_submission

  get ':actor/applications', constraints: { actor: /candidate|provider|referee/ }, controller: 'candidate_applications', action: :index, as: :tt_applications
  post ':actor/applications/:id', constraints: { actor: /candidate|provider|referee/ }, controller: 'candidate_applications', action: :update, as: :tt_application_update
end
