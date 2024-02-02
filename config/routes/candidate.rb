# No Devise modules are enabled
# Custom, magic-link based authentication flow used. See, for example -
# CandidateInterface::SignInController
devise_for :candidates, skip: :all

devise_scope :candidate do
  get '/candidate/sign-out', to: 'devise/sessions#destroy', as: :candidate_interface_sign_out
end

namespace :candidate_interface, path: '/candidate' do
  if HostingEnvironment.production?
    get '/' => redirect(GOVUK_APPLY_START_PAGE_URL)
  else
    get '/' => redirect('/')
  end

  get '/accessibility', to: 'content#accessibility'
  get '/cookies', to: 'content#cookies_page', as: :cookies
  get '/make-a-complaint', to: 'content#complaints', as: :complaints
  get '/privacy-policy', to: 'content#privacy_policy', as: :privacy_policy
  get '/providers', to: 'content#providers', as: :providers
  get '/terms-of-use', to: 'content#terms_candidate', as: :terms
  get '/guidance-for-using-ai', to: 'content#guidance_for_using_ai'
  post '/feedback-survey' => 'rejection_feedback_survey#new', as: :rejection_feedback_survey

  resources :cookie_preferences, only: 'create', path: 'cookie-preferences'
  post '/cookie-preferences-hide-confirmation', to: 'cookie_preferences#hide_confirmation', as: :cookie_preferences_hide_confirmation

  get '/account', to: 'start_page#create_account_or_sign_in', as: :create_account_or_sign_in
  post '/account', to: 'start_page#create_account_or_sign_in_handler'
  get '/applications-closed' => 'start_page#applications_closed', as: :applications_closed

  get '/sign-up', to: 'sign_up#new', as: :sign_up
  post '/sign-up', to: 'sign_up#create'
  get '/sign-up/check-email', to: 'sign_in#check_your_email', as: :check_email_sign_up
  get '/sign-up/external-sign-up-forbidden', to: 'sign_up#external_sign_up_forbidden', as: :external_sign_up_forbidden

  get '/sign-in', to: 'sign_in#new', as: :sign_in
  post '/sign-in', to: 'sign_in#create'
  post '/sign-in/expired', to: 'sign_in#create_from_expired_token', as: :create_expired_sign_in
  get '/sign-in/check-email', to: 'sign_in#check_your_email', as: :check_email_sign_in
  get '/sign-in/expired', to: 'sign_in#expired', as: :expired_sign_in

  get '/confirm_authentication', to: redirect('/candidate/sign-in/confirm')
  get '/sign-in/confirm', to: 'sign_in#confirm_authentication', as: :authenticate
  post '/sign-in/confirm', to: 'sign_in#authenticate'
  get '/authenticate', to: 'sign_in#expired'

  get '/apply', to: 'apply_from_find#show', as: :apply_from_find

  get '/interstitial', to: 'after_sign_in#interstitial', as: :interstitial

  scope '/find-feedback' do
    get '/' => 'find_feedback#new', as: :find_feedback
    post '/' => 'find_feedback#create'
    get '/thank-you' => 'find_feedback#thank_you', as: :find_feedback_thank_you
  end

  scope '/application' do
    get '/details', to: 'continuous_applications_details#index', as: :continuous_applications_details
    get '/choices', to: 'continuous_applications_choices#index', as: :continuous_applications_choices

    get '/prefill', to: 'prefill_application_form#new'
    post '/prefill', to: 'prefill_application_form#create'

    get '/' => 'unsubmitted_application_form#show', as: :application_form
    get '/review' => 'unsubmitted_application_form#review', as: :application_review
    get '/submit' => 'unsubmitted_application_form#submit_show', as: :application_submit_show

    get '/complete' => 'submitted_application_form#complete', as: :application_complete
    get '/review/submitted' => 'submitted_application_form#review_submitted', as: :application_review_submitted

    scope '/manage-conditions' do
      get '/' => 'offer_dashboard#show', as: :application_offer_dashboard
      get '/reference/:id' => 'offer_dashboard#view_reference', as: :application_offer_dashboard_reference
    end

    get '/review/submitted/:id' => 'application_form#review_previous_application', as: :review_previous_application

    get '/start-carry-over' => 'carry_over#start', as: :start_carry_over
    post '/carry-over' => 'carry_over#create', as: :carry_over

    resources :adviser_sign_ups, only: %i[new create], path: 'adviser-sign-ups'

    scope '/personal-details' do
      get '/', to: redirect('/candidate/application/personal-information')
      get '/edit', to: redirect('/candidate/application/personal-information/edit')
      get '/nationalities', to: redirect('/candidate/application/personal-information/nationality'), as: :personal_details_nationalities
      get '/nationalities/edit', to: redirect('/candidate/application/personal-information/nationality/edit'), as: :personal_details_edit_nationalities
      get '/right-to-work-or-study', to: redirect('/candidate/application/personal-information/right-to-work-or-study'), as: :personal_details_right_to_work_or_study
      get '/right-to-work-or-study/edit', to: redirect('/candidate/application/personal-information/right-to-work-or-study/edit'), as: :personal_details_edit_right_to_work_or_study
      get 'review', to: redirect('/candidate/application/personal-information/review')
    end

    scope '/personal-information' do
      get '/' => 'personal_details/name_and_dob#new', as: :name_and_dob
      patch '/' => 'personal_details/name_and_dob#create'
      get '/edit' => 'personal_details/name_and_dob#edit', as: :edit_name_and_dob
      patch '/edit' => 'personal_details/name_and_dob#update'

      get '/nationality' => 'personal_details/nationalities#new', as: :nationalities
      patch '/nationality' => 'personal_details/nationalities#create'
      get '/nationality/edit' => 'personal_details/nationalities#edit', as: :edit_nationalities
      patch '/nationality/edit' => 'personal_details/nationalities#update'

      get '/right-to-work-or-study' => 'personal_details/immigration_right_to_work#new', as: :right_to_work_or_study
      patch '/right-to-work-or-study' => 'personal_details/immigration_right_to_work#create'
      get '/right-to-work-or-study/edit' => 'personal_details/immigration_right_to_work#edit', as: :edit_right_to_work_or_study
      patch '/right-to-work-or-study/edit' => 'personal_details/immigration_right_to_work#update'

      get '/immigration-right-to-work' => 'personal_details/immigration_right_to_work#new', as: :immigration_right_to_work
      patch '/immigration-right-to-work' => 'personal_details/immigration_right_to_work#create'
      get '/immigration-right-to-work/edit' => 'personal_details/immigration_right_to_work#edit', as: :edit_immigration_right_to_work
      patch '/immigration-right-to-work/edit' => 'personal_details/immigration_right_to_work#update'
      get '/immigration-status' => 'personal_details/immigration_status#new', as: :immigration_status
      patch '/immigration-status' => 'personal_details/immigration_status#create'
      get '/immigration-status/edit' => 'personal_details/immigration_status#edit', as: :edit_immigration_status
      patch '/immigration-status/edit' => 'personal_details/immigration_status#update'

      get '/review' => 'personal_details/review#show', as: :personal_details_show
      patch '/review' => 'personal_details/review#complete', as: :personal_details_complete
    end

    scope '/personal-statement' do
      get '/' => 'personal_statement#new', as: :new_becoming_a_teacher
      patch '/' => 'personal_statement#create'
      get '/edit' => 'personal_statement#edit', as: :edit_becoming_a_teacher
      patch '/edit' => 'personal_statement#update'
      get '/review' => 'personal_statement#show', as: :becoming_a_teacher_show
      patch '/complete' => 'personal_statement#complete', as: :becoming_a_teacher_complete
    end

    scope '/interview-availability' do
      get '/' => 'interview_availability#new', as: :new_interview_preferences
      patch '/' => 'interview_availability#create'
      get '/edit' => 'interview_availability#edit', as: :edit_interview_preferences
      patch '/edit' => 'interview_availability#update'
      get '/review' => 'interview_availability#show', as: :interview_preferences_show
      patch '/complete' => 'interview_availability#complete', as: :interview_preferences_complete
    end

    # Redirects for rerouting interview-needs to interview-availability
    # status is 301 moved permanently by default
    scope '/interview-needs' do
      get '/', to: redirect('/candidate/application/interview-availability')
      get '/edit', to: redirect('/candidate/application/interview-availability/edit')
      get '/review', to: redirect('/candidate/application/interview-availability/review')
    end

    scope '/training-with-a-disability' do
      get '/', to: redirect('/candidate/application/additional-support')
      get '/review', to: redirect('/candidate/application/additional-support/review')
    end

    scope '/additional-support' do
      get '/' => 'training_with_a_disability#new', as: :new_training_with_a_disability
      patch '/' => 'training_with_a_disability#create'
      get '/edit' => 'training_with_a_disability#edit', as: :edit_training_with_a_disability
      patch '/edit' => 'training_with_a_disability#update'
      get '/review' => 'training_with_a_disability#show', as: :training_with_a_disability_show
      patch '/complete' => 'training_with_a_disability#complete', as: :training_with_a_disability_complete
    end

    scope '/contact-details' do
      get '/', to: redirect('/candidate/application/contact-information/phone-number')
      get '/address_type', to: redirect('/candidate/application/contact-information/address-type')
      get '/address', to: redirect('/candidate/application/contact-information/address')
      get '/review', to: redirect('/candidate/application/contact-information/review')
    end

    scope '/contact-information' do
      get '/phone-number' => 'contact_details/phone_number#new', as: :new_phone_number
      post '/phone-number' => 'contact_details/phone_number#create'
      get '/phone-number/edit' => 'contact_details/phone_number#edit', as: :edit_phone_number
      patch '/phone-number/edit' => 'contact_details/phone_number#update'

      get '/address-type' => 'contact_details/address_type#new', as: :new_address_type
      post '/address-type' => 'contact_details/address_type#create'
      get '/address-type/edit' => 'contact_details/address_type#edit', as: :edit_address_type
      patch '/address-type/edit' => 'contact_details/address_type#update'

      get '/address' => 'contact_details/address#new', as: :new_address
      post '/address' => 'contact_details/address#create'
      get '/address/edit' => 'contact_details/address#edit', as: :edit_address
      patch '/address/edit' => 'contact_details/address#update'

      get '/review' => 'contact_details/review#show', as: :contact_information_review
      patch '/complete' => 'contact_details/review#complete', as: :contact_information_complete
    end

    scope '/gcse' do
      get '/maths/grade' => 'gcse/maths/grade#new', as: :new_gcse_maths_grade
      patch '/maths/grade' => 'gcse/maths/grade#create'
      get '/maths/grade/edit' => 'gcse/maths/grade#edit', as: :edit_gcse_maths_grade
      patch '/maths/grade/edit' => 'gcse/maths/grade#update'

      get '/english/grade' => 'gcse/english/grade#new', as: :new_gcse_english_grade
      patch '/english/grade' => 'gcse/english/grade#create'
      get '/english/grade/edit' => 'gcse/english/grade#edit', as: :edit_gcse_english_grade
      patch '/english/grade/edit' => 'gcse/english/grade#update'

      get '/science/grade' => 'gcse/science/grade#new', as: :new_gcse_science_grade
      patch '/science/grade' => 'gcse/science/grade#create'
      get '/science/grade/edit' => 'gcse/science/grade#edit', as: :edit_gcse_science_grade
      patch '/science/grade/edit' => 'gcse/science/grade#update'
    end

    scope '/gcse/:subject', constraints: { subject: /(maths|english|science)/ } do
      get '/' => 'gcse/type#new', as: :gcse_details_new_type
      post '/' => 'gcse/type#create'
      get '/edit' => 'gcse/type#edit', as: :gcse_details_edit_type
      patch '/edit' => 'gcse/type#update'

      get '/not-yet-completed' => 'gcse/not_completed_qualification#new', as: :gcse_not_yet_completed
      patch '/not-yet-completed' => 'gcse/not_completed_qualification#create'
      get '/not-yet-completed/edit' => 'gcse/not_completed_qualification#edit', as: :gcse_edit_not_yet_completed
      patch '/not-yet-completed/edit' => 'gcse/not_completed_qualification#update'

      get '/equivalency' => 'gcse/missing_qualification#new', as: :gcse_missing
      patch '/equivalency' => 'gcse/missing_qualification#create'
      get '/equivalency/edit' => 'gcse/missing_qualification#edit', as: :gcse_edit_missing
      patch '/equivalency/edit' => 'gcse/missing_qualification#update'

      get '/country' => 'gcse/institution_country#new', as: :gcse_details_new_institution_country
      patch '/country' => 'gcse/institution_country#create'
      get '/country/edit' => 'gcse/institution_country#edit', as: :gcse_details_edit_institution_country
      patch '/country/edit' => 'gcse/institution_country#update'

      get '/enic' => 'gcse/enic#new', as: :gcse_details_new_enic
      patch '/enic' => 'gcse/enic#create'
      get '/enic/edit' => 'gcse/enic#edit', as: :gcse_details_edit_enic
      patch '/enic/edit' => 'gcse/enic#update'

      get '/grade-explanation' => 'gcse/grade_explanation#new', as: :gcse_details_new_grade_explanation
      patch '/grade-explanation' => 'gcse/grade_explanation#create'
      get '/grade-explanation/edit' => 'gcse/grade_explanation#edit', as: :gcse_details_edit_grade_explanation
      patch '/grade-explanation/edit' => 'gcse/grade_explanation#update'

      get '/year' => 'gcse/year#new', as: :gcse_details_new_year
      patch '/year' => 'gcse/year#create'
      get '/year/edit' => 'gcse/year#edit', as: :gcse_details_edit_year
      patch '/year/edit' => 'gcse/year#update'

      get '/review' => 'gcse/review#show', as: :gcse_review
      patch '/complete' => 'gcse/review#complete', as: :gcse_complete
    end

    scope '/restructured-work-history' do
      get '/' => 'restructured_work_history/start#choice', as: :restructured_work_history
      post '/' => 'restructured_work_history/start#submit_choice'

      get '/new' => 'restructured_work_history/jobs#new', as: :new_restructured_work_history
      post '/new' => 'restructured_work_history/jobs#create'

      get '/edit/:id' => 'restructured_work_history/jobs#edit', as: :edit_restructured_work_history
      patch '/edit/:id' => 'restructured_work_history/jobs#update'

      get '/delete/:id' => 'restructured_work_history/jobs#confirm_destroy', as: :destroy_restructured_work_history
      delete '/delete/:id' => 'restructured_work_history/jobs#destroy'

      get '/explain-break/new' => 'restructured_work_history/break#new', as: :new_restructured_work_history_break
      post '/explain-break/new' => 'restructured_work_history/break#create'

      get '/explain-break/edit/:id' => 'restructured_work_history/break#edit', as: :edit_restructured_work_history_break
      patch '/explain-break/edit/:id' => 'restructured_work_history/break#update'

      get '/explain-break/delete/:id' => 'restructured_work_history/break#confirm_destroy', as: :destroy_restructured_work_history_break
      delete '/explain-break/delete/:id' => 'restructured_work_history/break#destroy'

      get '/review' => 'restructured_work_history/review#show', as: :restructured_work_history_review
      patch '/review' => 'restructured_work_history/review#complete', as: :restructured_work_history_complete
    end

    scope '/school-experience' do
      get '/', to: redirect('/candidate/application/unpaid-experience')
      get '/new', to: redirect('/candidate/application/unpaid-experience/new')
      get '/edit/:id', to: redirect { |params, _| "/candidate/application/unpaid-experience/edit/#{params[:id]}" }
      get '/review', to: redirect('/candidate/application/unpaid-experience/review')
      get '/delete/:id', to: redirect { |params, _| "/candidate/application/unpaid-experience/delete/#{params[:id]}" }
    end

    scope '/unpaid-experience' do
      get '/' => 'volunteering/start#show', as: :volunteering_experience
      post '/' => 'volunteering/start#submit'

      get '/new' => 'volunteering/roles#new', as: :new_volunteering_role
      post '/new' => 'volunteering/roles#create'

      get '/edit/:id' => 'volunteering/roles#edit', as: :edit_volunteering_role
      patch '/edit/:id' => 'volunteering/roles#update'

      get '/review' => 'volunteering/review#show', as: :review_volunteering
      patch '/review' => 'volunteering/review#complete', as: :complete_volunteering

      get '/delete/:id' => 'volunteering/destroy#confirm_destroy', as: :confirm_destroy_volunteering_role
      delete '/delete/:id' => 'volunteering/destroy#destroy'
    end

    scope '/degrees' do
      constraints ValidDegreeStep do
        get '/country' => 'degrees/degree#new_country', as: :degree_country
        post '/country' => 'degrees/degree#update_country'

        get '/edit/:id/:step' => 'degrees/degree#edit', as: :degree_edit

        get '/level' => 'degrees/degree#new_degree_level', as: :degree_degree_level
        post '/level' => 'degrees/degree#update_degree_level'

        get '/subject' => 'degrees/degree#new_subject', as: :degree_subject
        post '/subject' => 'degrees/degree#update_subject'

        get '/grade' => 'degrees/degree#new_grade', as: :degree_grade
        post '/grade' => 'degrees/degree#update_grade'

        get '/start-year' => 'degrees/degree#new_start_year', as: :degree_start_year
        post '/start-year' => 'degrees/degree#update_start_year'

        get '/graduation-year' => 'degrees/degree#new_award_year', as: :degree_award_year
        post '/graduation-year' => 'degrees/degree#update_award_year'

        get '/enic' => 'degrees/degree#new_enic', as: :degree_enic
        post '/enic' => 'degrees/degree#update_enic'

        get '/types' => 'degrees/degree#new_type', as: :degree_type
        post '/types' => 'degrees/degree#update_type'

        get '/university' => 'degrees/degree#new_university', as: :degree_university
        post '/university' => 'degrees/degree#update_university'

        get  '/completed' => 'degrees/degree#new_completed', as: :degree_completed
        post '/completed' => 'degrees/degree#update_completed'
      end

      get '/review' => 'degrees/review#show', as: :degree_review
      patch '/review' => 'degrees/review#complete', as: :degree_complete

      get '/delete/:id' => 'degrees/destroy#confirm_destroy', as: :confirm_degree_destroy
      delete '/delete/:id' => 'degrees/destroy#destroy'
    end

    scope '/continuous-applications' do
      get '/choose' => 'continuous_applications/course_choices/do_you_know_which_course#new', as: :continuous_applications_do_you_know_the_course
      post '/choose' => 'continuous_applications/course_choices/do_you_know_which_course#create'

      get '/go-to-find' => 'continuous_applications/course_choices/go_to_find#new', as: :continuous_applications_go_to_find_explanation

      get '/provider' => 'continuous_applications/course_choices/provider_selection#new', as: :continuous_applications_provider_selection
      post '/provider' => 'continuous_applications/course_choices/provider_selection#create'

      get '/provider/:provider_id/course' => 'continuous_applications/course_choices/which_course_are_you_applying_to#new', as: :continuous_applications_which_course_are_you_applying_to
      post '/provider/:provider_id/course' => 'continuous_applications/course_choices/which_course_are_you_applying_to#create'
      get '/:application_choice_id/review' => 'continuous_applications/course_choices/review#show', as: :continuous_applications_course_review
      get '/:application_choice_id/review-interruption' => 'continuous_applications/course_choices/review_interruption#show', as: :continuous_applications_course_review_interruption
      get '/:application_choice_id/review-and-submit' => 'continuous_applications/course_choices/review_and_submit#show', as: :continuous_applications_course_review_and_submit
      get '/blocked-submissions' => 'continuous_applications/course_choices/blocked_submissions#show', as: :continuous_applications_blocked_submissions

      get '/provider/:provider_id/courses/:course_id/reached-reapplication-limit' => 'continuous_applications/course_choices/reached_reapplication_limit#new', as: :continuous_applications_reached_reapplication_limit
      get '/provider/:provider_id/courses/:course_id/duplicate' => 'continuous_applications/course_choices/duplicate_course_selection#new', as: :continuous_applications_duplicate_course_selection
      get '/provider/:provider_id/courses/:course_id/full' => 'continuous_applications/course_choices/full_course_selection#new', as: :continuous_applications_full_course_selection

      get '/provider/:provider_id/courses/:course_id' => 'continuous_applications/course_choices/course_study_mode#new', as: :continuous_applications_course_study_mode
      post '/provider/:provider_id/courses/:course_id' => 'continuous_applications/course_choices/course_study_mode#create'

      get '/provider/:provider_id/courses/:course_id/:study_mode' => 'continuous_applications/course_choices/course_site#new', as: :continuous_applications_course_site
      post '/provider/:provider_id/courses/:course_id/:study_mode' => 'continuous_applications/course_choices/course_site#create'

      get '/:application_choice_id/courses/edit' => 'continuous_applications/course_choices/which_course_are_you_applying_to#edit', as: :edit_continuous_applications_which_course_are_you_applying_to
      patch '/:application_choice_id/courses/edit' => 'continuous_applications/course_choices/which_course_are_you_applying_to#update'
      get '/:application_choice_id/courses/:course_id/edit' => 'continuous_applications/course_choices/course_study_mode#edit', as: :edit_continuous_applications_course_study_mode
      patch '/:application_choice_id/courses/:course_id/edit' => 'continuous_applications/course_choices/course_study_mode#update'
      get '/:application_choice_id/courses/:course_id/:study_mode/edit' => 'continuous_applications/course_choices/course_site#edit', as: :edit_continuous_applications_course_site
      patch '/:application_choice_id/courses/:course_id/:study_mode/edit' => 'continuous_applications/course_choices/course_site#update'

      get '/confirm-selection/:course_id' => 'continuous_applications/course_choices/find_course_selection#new', as: :continuous_applications_course_confirm_selection
      post '/confirm-selection/:course_id' => 'continuous_applications/course_choices/find_course_selection#create'

      post '/:id/submit' => 'continuous_applications/application_choices#submit', as: :continuous_applications_submit_course_choice
      get '/delete/:id' => 'continuous_applications/application_choices#confirm_destroy', as: :continuous_applications_confirm_destroy_course_choice
      delete '/delete/:id' => 'continuous_applications/application_choices#destroy'
    end

    scope '/choice/:id' do
      get '/offer' => 'decisions#offer', as: :offer
      post '/offer/respond' => 'decisions#respond_to_offer', as: :respond_to_offer

      get '/offer/decline' => 'decisions#decline_offer', as: :decline_offer
      post '/offer/decline' => 'decisions#confirm_decline'

      get '/offer/accept' => 'decisions#accept_offer', as: :accept_offer
      post '/offer/accept' => 'decisions#confirm_accept'

      get '/withdraw' => 'decisions#withdraw', as: :withdraw
      post '/withdraw' => 'decisions#confirm_withdraw'

      get '/withdraw/feedback' => 'decisions#withdrawal_feedback', as: :withdrawal_feedback
      post '/withdraw/confirm-feedback' => 'decisions#confirm_withdrawal_feedback', as: :confirm_withdrawal_feedback
    end

    scope '/other-qualifications' do
      get '/' => 'other_qualifications/type#new', as: :other_qualification_type
      post '/' => 'other_qualifications/type#create'
      get '/type/edit/:id' => 'other_qualifications/type#edit', as: :edit_other_qualification_type
      patch '/type/edit/:id' => 'other_qualifications/type#update'

      get '/details' => 'other_qualifications/details#new', as: :other_qualification_details
      patch '/details' => 'other_qualifications/details#create'
      get '/details/edit/:id' => 'other_qualifications/details#edit', as: :edit_other_qualification_details
      patch '/details/edit/:id' => 'other_qualifications/details#update'

      get '/review' => 'other_qualifications/review#show', as: :review_other_qualifications
      patch '/review' => 'other_qualifications/review#complete', as: :complete_other_qualifications

      get '/delete/:id' => 'other_qualifications/destroy#confirm_destroy', as: :confirm_destroy_other_qualification
      delete '/delete/:id' => 'other_qualifications/destroy#destroy'
    end

    scope '/english-as-a-foreign-language' do
      get '/' => 'english_foreign_language/start#new', as: :english_foreign_language_start
      post '/' => 'english_foreign_language/start#create'
      get '/edit' => 'english_foreign_language/start#edit', as: :english_foreign_language_edit_start
      patch '/edit' => 'english_foreign_language/start#update'

      get '/type' => 'english_foreign_language/type#new', as: :english_foreign_language_type
      post '/type' => 'english_foreign_language/type#create'

      get '/ielts' => 'english_foreign_language/ielts#new', as: :ielts
      post '/ielts' => 'english_foreign_language/ielts#create'
      get '/ielts/edit' => 'english_foreign_language/ielts#edit', as: :edit_ielts
      patch '/ielts/edit' => 'english_foreign_language/ielts#update'

      get '/toefl' => 'english_foreign_language/toefl#new', as: :toefl
      post '/toefl' => 'english_foreign_language/toefl#create'
      get '/toefl/edit' => 'english_foreign_language/toefl#edit', as: :edit_toefl
      patch '/toefl/edit' => 'english_foreign_language/toefl#update'

      get '/other' => 'english_foreign_language/other_efl_qualification#new', as: :other_efl_qualification
      post '/other' => 'english_foreign_language/other_efl_qualification#create'
      get '/other/edit' => 'english_foreign_language/other_efl_qualification#edit', as: :edit_other_efl_qualification
      patch '/other/edit' => 'english_foreign_language/other_efl_qualification#update'

      get '/review' => 'english_foreign_language/review#show', as: :english_foreign_language_review
      patch '/review' => 'english_foreign_language/review#complete', as: :english_foreign_language_complete
    end

    scope '/references' do
      get '/start' => 'references/review#show', as: :references_start

      get '/type/edit/:id' => 'references/type#edit', as: :references_edit_type
      patch '/type/edit/:id' => 'references/type#update'
      get '/type/(:referee_type)/(:id)' => 'references/type#new', as: :references_type
      post '/type/(:referee_type)/(:id)' => 'references/type#create'

      scope '/accept-offer/:application_id' do
        get '/type/edit/:id' => 'references/accept_offer/type#edit', as: :accept_offer_references_edit_type
        patch '/type/edit/:id' => 'references/accept_offer/type#update'
        get '/type/(:referee_type)/(:id)' => 'references/accept_offer/type#new', as: :accept_offer_references_type
        post '/type/(:referee_type)/(:id)' => 'references/accept_offer/type#create'

        scope '/name/:referee_type/(:id)', constraints: { referee_type: /(academic|professional|school-based|character)/ } do
          get '/' => 'references/accept_offer/name#new', as: :accept_offer_references_name
          patch '/' => 'references/accept_offer/name#create'
        end
        get '/name/edit/:id' => 'references/accept_offer/name#edit', as: :accept_offer_references_edit_name
        patch '/name/edit/:id' => 'references/accept_offer/name#update'

        get '/email/:id' => 'references/accept_offer/email_address#new', as: :accept_offer_references_email_address
        patch '/email/:id' => 'references/accept_offer/email_address#create'
        get '/email/edit/:id' => 'references/accept_offer/email_address#edit', as: :accept_offer_references_edit_email_address
        patch '/email/edit/:id' => 'references/accept_offer/email_address#update'

        get '/relationship/:id' => 'references/accept_offer/relationship#new', as: :accept_offer_references_relationship
        patch '/relationship/:id' => 'references/accept_offer/relationship#create'
        get '/relationship/edit/:id' => 'references/accept_offer/relationship#edit', as: :accept_offer_references_edit_relationship
        patch '/relationship/edit/:id' => 'references/accept_offer/relationship#update'

        get '/review/delete-reference/:id' => 'references/accept_offer/review#confirm_destroy_reference', as: :accept_offer_confirm_destroy_new_reference
        delete '/review/delete/:id' => 'references/accept_offer/review#destroy', as: :accept_offer_destroy_new_reference
      end

      scope '/request-references' do
        get '/start/' => 'references/request_reference/start#new', as: :request_reference_references_start
        get '/type/edit/:id' => 'references/request_reference/type#edit', as: :request_reference_references_edit_type
        patch '/type/edit/:id' => 'references/request_reference/type#update'
        get '/type/(:referee_type)/(:id)' => 'references/request_reference/type#new', as: :request_reference_references_type
        post '/type/(:referee_type)/(:id)' => 'references/request_reference/type#create'

        scope '/name/:referee_type/(:id)', constraints: { referee_type: /(academic|professional|school-based|character)/ } do
          get '/' => 'references/request_reference/name#new', as: :request_reference_references_name
          patch '/' => 'references/request_reference/name#create'
        end
        get '/name/edit/:id' => 'references/request_reference/name#edit', as: :request_reference_references_edit_name
        patch '/name/edit/:id' => 'references/request_reference/name#update'

        get '/email/:id' => 'references/request_reference/email_address#new', as: :request_reference_references_email_address
        patch '/email/:id' => 'references/request_reference/email_address#create'
        get '/email/edit/:id' => 'references/request_reference/email_address#edit', as: :request_reference_references_edit_email_address
        patch '/email/edit/:id' => 'references/request_reference/email_address#update'

        get '/relationship/:id' => 'references/request_reference/relationship#new', as: :request_reference_references_relationship
        patch '/relationship/:id' => 'references/request_reference/relationship#create'
        get '/relationship/edit/:id' => 'references/request_reference/relationship#edit', as: :request_reference_references_edit_relationship
        patch '/relationship/edit/:id' => 'references/request_reference/relationship#update'

        get '/review/:id' => 'references/request_reference/review#new', as: :references_request_reference_review
        post '/review/:id' => 'references/request_reference/review#request_feedback', as: :references_request_reference_request_feedback
      end

      scope '/name/:referee_type/(:id)', constraints: { referee_type: /(academic|professional|school-based|character)/ } do
        get '/' => 'references/name#new', as: :references_name
        patch '/' => 'references/name#create'
      end
      get '/name/edit/:id' => 'references/name#edit', as: :references_edit_name
      patch '/name/edit/:id' => 'references/name#update'

      get '/email/:id' => 'references/email_address#new', as: :references_email_address
      patch '/email/:id' => 'references/email_address#create'
      get '/email/edit/:id' => 'references/email_address#edit', as: :references_edit_email_address
      patch '/email/edit/:id' => 'references/email_address#update'

      get '/relationship/:id' => 'references/relationship#new', as: :references_relationship
      patch '/relationship/:id' => 'references/relationship#create'
      get '/relationship/edit/:id' => 'references/relationship#edit', as: :references_edit_relationship
      patch '/relationship/edit/:id' => 'references/relationship#update'

      get '/review' => 'references/review#show', as: :references_review
      get '/review/delete-reference/:id' => 'references/review#confirm_destroy_reference', as: :confirm_destroy_new_reference
      delete '/review/delete/:id' => 'references/review#destroy', as: :destroy_new_reference

      get '/reminder/:id' => 'references/reminder#new', as: :references_new_reminder
      post '/reminder/:id' => 'references/reminder#create'

      get '/cancel/:id' => 'references/cancel#new', as: :references_confirm_cancel_reference
      patch '/cancel/:id' => 'references/cancel#confirm'

      patch '/review' => 'references/review#complete', as: :references_complete
    end

    scope '/equality-and-diversity' do
      get '/' => 'equality_and_diversity#start', as: :start_equality_and_diversity

      get '/sex' => 'equality_and_diversity#edit_sex', as: :edit_equality_and_diversity_sex
      patch '/sex' => 'equality_and_diversity#update_sex'

      get '/disabilities' => 'equality_and_diversity#edit_disabilities', as: :edit_equality_and_diversity_disabilities
      patch '/disabilities' => 'equality_and_diversity#update_disabilities'

      get '/ethnic-group' => 'equality_and_diversity#edit_ethnic_group', as: :edit_equality_and_diversity_ethnic_group
      patch '/ethnic-group' => 'equality_and_diversity#update_ethnic_group'

      get '/ethnic-background' => 'equality_and_diversity#edit_ethnic_background', as: :edit_equality_and_diversity_ethnic_background
      patch '/ethnic-background' => 'equality_and_diversity#update_ethnic_background'

      get '/free-school-meals' => 'equality_and_diversity#edit_free_school_meals', as: :edit_equality_and_diversity_free_school_meals
      patch '/free-school-meals' => 'equality_and_diversity#update_free_school_meals'

      get '/review' => 'equality_and_diversity#review', as: :review_equality_and_diversity
      post '/complete' => 'equality_and_diversity#complete', as: :complete_equality_and_diversity
    end

    scope '/safeguarding' do
      get '/' => 'safeguarding#new', as: :new_safeguarding
      patch '/' => 'safeguarding#create'
      get '/edit' => 'safeguarding#edit', as: :edit_safeguarding
      patch '/edit' => 'safeguarding#update'
      get '/review' => 'safeguarding#show', as: :review_safeguarding
      post '/complete' => 'safeguarding#complete', as: :complete_safeguarding
    end

    scope '/feedback-form' do
      get '/' => 'feedback_form#new', as: :feedback_form
      post '/' => 'feedback_form#create'
      get '/thank-you' => 'feedback_form#thank_you', as: :feedback_form_thank_you
    end

    scope '/application-feedback' do
      get '/' => 'application_feedback#new', as: :application_feedback
      post '/' => 'application_feedback#create'
      get '/thank-you' => 'application_feedback#thank_you', as: :application_feedback_thank_you
    end
  end

  get '/account-locked', to: 'errors#account_locked'

  get '/about-the-teacher-training-application-process', to: 'guidance#index', as: :guidance

  get '*path', to: 'errors#not_found'
end
