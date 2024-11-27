namespace :referee_interface, path: '/reference' do
  get '/' => 'reference#refuse_feedback', as: :refuse_feedback
  patch '/' => 'reference#confirm_feedback_refusal'

  get '/confidentiality' => 'reference#confidentiality', as: :confidentiality
  patch '/confidentiality' => 'reference#confirm_confidentiality'

  get '/relationship' => 'reference#relationship', as: :reference_relationship
  patch '/confirm-relationship' => 'reference#confirm_relationship', as: :confirm_relationship

  get '/safeguarding' => 'reference#safeguarding', as: :safeguarding
  patch '/confirm-safeguarding' => 'reference#confirm_safeguarding', as: :confirm_safeguarding

  get '/feedback' => 'reference#feedback', as: :reference_feedback

  get '/confirmation' => 'reference#confirmation', as: :confirmation
  patch '/confirmation' => 'reference#submit_feedback', as: :submit_feedback

  get '/review' => 'reference#review', as: :reference_review
  patch '/submit' => 'reference#submit_reference', as: :submit_reference

  patch '/questionnaire' => 'reference#submit_questionnaire', as: :submit_questionnaire
  get '/finish' => 'reference#finish', as: :finish

  get '/decline' => 'reference#confirm_decline', as: :decline_reference
  patch '/decline' => 'reference#decline'

  get '/thank-you' => 'reference#thank_you', as: :thank_you

  get '/refuse-feedback', to: redirect(path: '/reference')
end
