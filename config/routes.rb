Rails.application.routes.draw do
  # No Devise modules are enabled
  # Custom Warden strategy is used instead see app/warden/magic_link_token.rb
  # Custom views are used, see app/views/magic_link/sign_up/
  devise_for :candidates, skip: :all

  devise_scope :candidate do
    get '/candidate/sign-out', to: 'devise/sessions#destroy', as: :candidate_interface_sign_out
  end

  if HostingEnvironment.sandbox_mode?
    root to: 'content#sandbox'
  else
    root to: redirect('/candidate')
  end

  namespace :candidate_interface, path: '/candidate' do
    get '/' => 'start_page#show', as: :start

    get '/accessibility', to: 'content#accessibility'
    get '/privacy-policy', to: 'content#privacy_policy', as: :privacy_policy
    get '/cookies', to: 'content#cookies_candidate', as: :cookies
    get '/terms-of-use', to: 'content#terms_candidate', as: :terms
    get '/providers', to: 'content#providers', as: :providers

    get '/account', to: 'start_page#create_account_or_sign_in', as: :create_account_or_sign_in
    post '/account', to: 'start_page#create_account_or_sign_in_handler'

    get '/eligibility' => 'start_page#eligibility', as: :eligibility
    post '/eligibility' => 'start_page#determine_eligibility'
    get '/not-eligible', to: 'start_page#not_eligible', as: :not_eligible

    get '/sign-up', to: 'sign_up#new', as: :sign_up
    post '/sign-up', to: 'sign_up#create'
    get '/sign-up/check-email', to: 'sign_in#check_your_email', as: :check_email_sign_up

    get '/sign-in', to: 'sign_in#new', as: :sign_in
    post '/sign-in', to: 'sign_in#create'
    post '/sign-in/expired', to: 'sign_in#create_from_expired_token', as: :create_expired_sign_in
    get '/sign-in/check-email', to: 'sign_in#check_your_email', as: :check_email_sign_in
    get '/sign-in/expired', to: 'sign_in#expired', as: :expired_sign_in

    get '/authenticate', to: 'sign_in#authenticate', as: :authenticate

    get '/apply', to: 'apply_from_find#show', as: :apply_from_find
    post '/apply', to: 'apply_from_find#ucas_or_apply'

    get '/interstitial', to: 'after_sign_in#interstitial', as: :interstitial

    scope '/application' do
      get '/review/submitted/:id' => 'application_form#review_previous_application', as: :review_previous_application

      get '/' => 'unsubmitted_application_form#show', as: :application_form
      get '/review' => 'unsubmitted_application_form#review', as: :application_review
      get '/before-you-start', to: 'unsubmitted_application_form#before_you_start'
      get '/submit' => 'unsubmitted_application_form#submit_show', as: :application_submit_show
      post '/submit' => 'unsubmitted_application_form#submit', as: :application_submit

      get '/complete' => 'submitted_application_form#complete', as: :application_complete
      get '/review/submitted' => 'submitted_application_form#review_submitted', as: :application_review_submitted
      get '/submit-success' => 'submitted_application_form#submit_success', as: :application_submit_success
      get '/edit' => 'submitted_application_form#edit', as: :application_edit
      get '/start-apply-again' => 'submitted_application_form#start_apply_again', as: :start_apply_again
      post '/apply-again' => 'submitted_application_form#apply_again', as: :apply_again

      scope '/personal-details' do
        get '/' => 'personal_details/base#new', as: :personal_details_new
        post '/' => 'personal_details/base#create', as: :personal_details_create
        get '/edit' => 'personal_details/base#edit', as: :personal_details_edit
        post '/edit' => 'personal_details/base#update', as: :personal_details_update
        get '/nationalities' => 'personal_details/nationalities#new', as: :nationalities
        post '/nationalities' => 'personal_details/nationalities#create'
        get '/nationalities/edit' => 'personal_details/nationalities#edit', as: :edit_nationalities
        post '/nationalities/edit' => 'personal_details/nationalities#update'
        get '/languages' => 'personal_details/languages#edit', as: :languages
        post '/languages' => 'personal_details/languages#update'
        get '/languages/edit' => 'personal_details/languages#edit', as: :edit_languages
        post '/languages/edit' => 'personal_details/languages#update'
        get '/right-to-work-or-study' => 'personal_details/right_to_work_or_study#new', as: :right_to_work_or_study
        post '/right-to-work-or-study' => 'personal_details/right_to_work_or_study#create'
        get '/right-to-work-or-study/edit' => 'personal_details/right_to_work_or_study#edit', as: :edit_right_to_work_or_study
        post '/right-to-work-or-study/edit' => 'personal_details/right_to_work_or_study#update'
        get '/review' => 'personal_details/review#show', as: :personal_details_show
        post '/review' => 'personal_details/review#complete', as: :personal_details_complete
      end

      scope '/personal-statement' do
        get '/becoming-a-teacher' => 'personal_statement/becoming_a_teacher#edit', as: :becoming_a_teacher_edit
        post '/becoming-a-teacher/review' => 'personal_statement/becoming_a_teacher#update', as: :becoming_a_teacher_update
        get '/becoming-a-teacher/review' => 'personal_statement/becoming_a_teacher#show', as: :becoming_a_teacher_show
        post '/becoming-a-teacher/complete' => 'personal_statement/becoming_a_teacher#complete', as: :becoming_a_teacher_complete

        get '/subject-knowledge' => 'personal_statement/subject_knowledge#edit', as: :subject_knowledge_edit
        post '/subject-knowledge/review' => 'personal_statement/subject_knowledge#update', as: :subject_knowledge_update
        get '/subject-knowledge/review' => 'personal_statement/subject_knowledge#show', as: :subject_knowledge_show
        post '/subject-knowledge/complete' => 'personal_statement/subject_knowledge#complete', as: :subject_knowledge_complete

        get '/interview-preferences' => 'personal_statement/interview_preferences#edit', as: :interview_preferences_edit
        post '/interview-preferences/review' => 'personal_statement/interview_preferences#update', as: :interview_preferences_update
        get '/interview-preferences/review' => 'personal_statement/interview_preferences#show', as: :interview_preferences_show
        post '/interview-preferences/complete' => 'personal_statement/interview_preferences#complete', as: :interview_preferences_complete
      end

      scope '/training-with-a-disability' do
        get '/' => 'training_with_a_disability#edit', as: :training_with_a_disability_edit
        post '/review' => 'training_with_a_disability#update', as: :training_with_a_disability_update
        get '/review' => 'training_with_a_disability#show', as: :training_with_a_disability_show
        post '/complete' => 'training_with_a_disability#complete', as: :training_with_a_disability_complete
      end

      scope '/contact-details' do
        get '/' => 'contact_details/base#edit', as: :contact_details_edit_base
        post '/' => 'contact_details/base#update', as: :contact_details_update_base

        get '/address_type' => 'contact_details/address_type#edit', as: :contact_details_edit_address_type
        post '/address_type' => 'contact_details/address_type#update', as: :contact_details_update_address_type

        get '/address' => 'contact_details/address#edit', as: :contact_details_edit_address
        post '/address' => 'contact_details/address#update', as: :contact_details_update_address

        get '/review' => 'contact_details/review#show', as: :contact_details_review
        post '/complete' => 'contact_details/review#complete', as: :contact_details_complete
      end

      scope '/gcse/:subject', constraints: { subject: /(maths|english|science)/ } do
        get '/' => 'gcse/type#edit', as: :gcse_details_edit_type
        post '/' => 'gcse/type#update', as: :gcse_details_update_type

        get '/country' => 'gcse/institution_country#edit', as: :gcse_details_edit_institution_country
        post '/country' => 'gcse/institution_country#update', as: :gcse_details_update_institution_country

        get '/naric-reference' => 'gcse/naric_reference#edit', as: :gcse_details_edit_naric_reference
        post '/naric-reference' => 'gcse/naric_reference#update', as: :gcse_details_update_naric_reference

        get '/grade' => 'gcse/grade#edit', as: :gcse_details_edit_grade
        patch '/grade' => 'gcse/grade#update', as: :gcse_details_update_grade

        get '/year' => 'gcse/year#edit', as: :gcse_details_edit_year
        patch '/year' => 'gcse/year#update', as: :gcse_details_update_year

        get '/review' => 'gcse/review#show', as: :gcse_review
        post '/complete' => 'gcse/review#complete', as: :gcse_complete
      end

      scope '/work-history' do
        get '/length' => 'work_history/length#show', as: :work_history_length
        post '/length' => 'work_history/length#submit'

        get '/missing' => 'work_history/explanation#show', as: :work_history_explanation
        post '/missing' => 'work_history/explanation#submit'

        get '/explain-breaks' => 'work_history/breaks#edit', as: :work_history_breaks
        post '/explain-breaks' => 'work_history/breaks#update'

        get '/explain-break/new' => 'work_history/break#new', as: :new_work_history_break
        post '/explain-break/new' => 'work_history/break#create'
        get '/explain-break/edit/:id' => 'work_history/break#edit', as: :edit_work_history_break
        post '/explain-break/edit/:id' => 'work_history/break#update'
        get '/explain-break/delete/:id' => 'work_history/break#confirm_destroy', as: :destroy_work_history_break
        post '/explain-break/delete/:id' => 'work_history/break#destroy'

        get '/new' => 'work_history/edit#new', as: :work_history_new
        post '/create' => 'work_history/edit#create', as: :work_history_create

        get '/edit/:id' => 'work_history/edit#edit', as: :work_history_edit
        post '/edit/:id' => 'work_history/edit#update'

        get '/review' => 'work_history/review#show', as: :work_history_show
        patch '/review' => 'work_history/review#complete', as: :work_history_complete

        get '/delete/:id' => 'work_history/destroy#confirm_destroy', as: :work_history_destroy
        delete '/delete/:id' => 'work_history/destroy#destroy'
      end

      scope '/school-experience' do
        get '/' => 'volunteering/experience#show', as: :volunteering_experience
        post '/' => 'volunteering/experience#submit'

        get '/new' => 'volunteering/base#new', as: :new_volunteering_role
        post '/new' => 'volunteering/base#create', as: :create_volunteering_role

        get '/edit/:id' => 'volunteering/base#edit', as: :edit_volunteering_role
        post '/edit/:id' => 'volunteering/base#update'

        get '/review' => 'volunteering/review#show', as: :review_volunteering
        patch '/review' => 'volunteering/review#complete', as: :complete_volunteering

        get '/delete/:id' => 'volunteering/destroy#confirm_destroy', as: :confirm_destroy_volunteering_role
        delete '/delete/:id' => 'volunteering/destroy#destroy'
      end

      scope '/degrees' do
        get '/' => 'degrees/type#new', as: :new_degree
        post '/' => 'degrees/type#create'
        get '/:id/type/edit' => 'degrees/type#edit', as: :edit_degree_type
        patch '/:id/type/edit' => 'degrees/type#update'

        get '/:id/subject' => 'degrees/subject#new', as: :degree_subject
        post '/:id/subject' => 'degrees/subject#create'
        get '/:id/subject/edit' => 'degrees/subject#edit', as: :edit_degree_subject
        patch '/:id/subject/edit' => 'degrees/subject#update'

        get '/:id/institution' => 'degrees/institution#new', as: :degree_institution
        post '/:id/institution' => 'degrees/institution#create'
        get '/:id/institution/edit' => 'degrees/institution#edit', as: :edit_degree_institution
        patch '/:id/institution/edit' => 'degrees/institution#update'

        get '/:id/naric-statement' => 'degrees/naric_statement#new', as: :degree_naric_statement
        post '/:id/naric-statement' => 'degrees/naric_statement#create'
        get '/:id/naric-statement/edit' => 'degrees/naric_statement#edit', as: :edit_degree_naric_statement
        patch '/:id/naric-statement/edit' => 'degrees/naric_statement#update'

        get '/:id/grade' => 'degrees/grade#new', as: :degree_grade
        post '/:id/grade' => 'degrees/grade#create'
        get '/:id/grade/edit' => 'degrees/grade#edit', as: :edit_degree_grade
        patch '/:id/grade/edit' => 'degrees/grade#update'

        get '/:id/year' => 'degrees/year#new', as: :degree_year
        post '/:id/year' => 'degrees/year#create'
        get '/:id/year/edit' => 'degrees/year#edit', as: :edit_degree_year
        patch '/:id/year/edit' => 'degrees/year#update'

        get '/review' => 'degrees/review#show', as: :degrees_review
        patch '/review' => 'degrees/review#complete', as: :degrees_complete

        get '/delete/:id' => 'degrees/destroy#confirm_destroy', as: :confirm_degree_destroy
        delete '/delete/:id' => 'degrees/destroy#destroy'
      end

      scope '/courses' do
        get '/' => 'application_choices#index', as: :course_choices_index
        get '/review' => 'application_choices#review', as: :course_choices_review
        patch '/review' => 'application_choices#complete', as: :course_choices_complete
        get '/delete/:id' => 'application_choices#confirm_destroy', as: :confirm_destroy_course_choice
        delete '/delete/:id' => 'application_choices#destroy'

        get '/choose' => 'course_choices/have_you_chosen#ask', as: :course_choices_choose
        post '/choose' => 'course_choices/have_you_chosen#decide'
        get '/find-a-course' => 'course_choices/have_you_chosen#go_to_find', as: :go_to_find
        get '/find_a_course', to: redirect('/candidate/application/courses/find-a-course')

        get '/provider' => 'course_choices/provider_selection#new', as: :course_choices_provider
        post '/provider' => 'course_choices/provider_selection#create'
        get '/provider/:provider_id/courses' => 'course_choices/course_selection#new', as: :course_choices_course
        post '/provider/:provider_id/courses' => 'course_choices/course_selection#create'
        get '/provider/:provider_id/courses/:course_id' => 'course_choices/study_mode_selection#new', as: :course_choices_study_mode
        post '/provider/:provider_id/courses/:course_id' => 'course_choices/study_mode_selection#create'
        get '/provider/:provider_id/courses/:course_id/full' => 'course_choices/course_selection#full', as: :course_choices_full
        get '/provider/:provider_id/courses/:course_id/:study_mode' => 'course_choices/site_selection#new', as: :course_choices_site
        post '/provider/:provider_id/courses/:course_id/:study_mode' => 'course_choices/site_selection#create'
        get '/another' => 'course_choices/add_another_course#ask', as: :course_choices_add_another_course
        post '/another' => 'course_choices/add_another_course#decide', as: :course_choices_add_another_course_selection

        get '/apply-on-ucas/provider/:provider_id' => 'course_choices/ucas#no_courses', as: :course_choices_ucas_no_courses
        get '/apply-on-ucas/provider/:provider_id/course/:course_id' => 'course_choices/ucas#with_course', as: :course_choices_ucas_with_course

        get '/confirm-selection/:course_id' => 'find_course_selections#confirm_selection', as: :course_confirm_selection
        get '/confirm_selection/:course_id', to: redirect('/candidate/application/courses/confirm-selection/%{course_id}')
        post '/complete-selection/:course_id' => 'find_course_selections#complete_selection', as: :course_complete_selection
        get '/complete_selection/:course_id', to: redirect('/candidate/application/courses/complete-selection/%{course_id}')

        scope '/replace' do
          get '/' => 'course_choices/replace_choices/base#pick_choice_to_replace', as: :replace_course_choices
          post '/' => 'course_choices/replace_choices/base#picked_choice'

          get '/:id' => 'course_choices/replace_choices/decision#choose_action', as: :replace_course_choice
          post '/:id' => 'course_choices/replace_choices/decision#route_action'

          get '/:id/choose' => 'course_choices/replace_choices/have_you_chosen#ask', as: :replace_course_choices_choose
          post '/:id/choose' => 'course_choices/replace_choices/have_you_chosen#decide'
          get '/:id/find-a-course' => 'course_choices/replace_choices/have_you_chosen#go_to_find', as: :replace_go_to_find

          get '/:id/provider' => 'course_choices/replace_choices/provider_selection#new', as: :replace_course_choice_provider
          post '/:id/provider' => 'course_choices/replace_choices/provider_selection#create'

          get '/:id/apply-on-ucas/provider/:provider_id' => 'course_choices/replace_choices/ucas#no_courses', as: :replace_course_choice_ucas_no_courses
          get '/:id/apply-on-ucas/provider/:provider_id/course/:course_id' => 'course_choices/replace_choices/ucas#with_course', as: :replace_course_choice_ucas_with_course

          get '/:id/provider/:provider_id/course' => 'course_choices/replace_choices/course_selection#new', as: :replace_course_choice_course
          post '/:id/provider/:provider_id/course' => 'course_choices/replace_choices/course_selection#create'
          get '/:id/provider/:provider_id/courses/:course_id/full' => 'course_choices/replace_choices/course_selection#full', as: :replace_course_choice_full

          get '/:id/provider/:provider_id/course/:course_id/study_mode' => 'course_choices/replace_choices/study_mode_selection#new', as: :replace_course_choice_study_mode
          post '/:id/provider/:provider_id/course/:course_id/study_mode' => 'course_choices/replace_choices/study_mode_selection#create'

          get '/:id/provider/:provider_id/course/:course_id/:study_mode/location' => 'course_choices/replace_choices/site_selection#new', as: :replace_course_choice_location
          get '/:id/location' => 'course_choices/replace_choices/site_selection#update', as: :replace_course_choice_update_location
          post '/:id/location' => 'course_choices/replace_choices/site_selection#validate_location', as: :replace_course_choice_validate_location

          get '/:id/confirm_cancel' => 'course_choices/replace_choices/cancel#confirm_cancel', as: :confirm_cancel_full_course_choice
          post '/:id/cancel' => 'course_choices/replace_choices/cancel#cancel', as: :cancel_full_course_choice

          get '/:id/confirm_withdraw' => 'course_choices/replace_choices/cancel#confirm_withdraw', as: :confirm_withdraw_full_course_choice
          post '/:id/withdraw' => 'course_choices/replace_choices/cancel#withdraw', as: :withdraw_full_course_choice

          get '/:id/confirm/:course_option_id' => 'course_choices/replace_choices/review#confirm_choice', as: :confirm_replacement_course_choice
          get '/:id/update/:course_option_id' => 'course_choices/replace_choices/review#update_choice', as: :update_replacement_course_choice
        end
      end

      scope '/choice/:id' do
        get '/offer' => 'decisions#offer', as: :offer
        post '/offer/respond' => 'decisions#respond_to_offer', as: :respond_to_offer

        get '/offer/decline' => 'decisions#decline', as: :decline_offer
        post '/offer/decline' => 'decisions#confirm_decline'

        get '/offer/accept' => 'decisions#accept', as: :accept_offer
        post '/offer/accept' => 'decisions#confirm_accept'

        get '/withdraw' => 'decisions#withdraw', as: :withdraw
        post '/withdraw' => 'decisions#confirm_withdraw'

        get '/withdraw/feedback' => 'decisions#feedback', as: :withdraw_feedback
        post '/withdraw/confirm-feedback' => 'decisions#confirm_feedback', as: :confirm_feedback
      end

      scope '/other-qualifications' do
        get '/' => 'other_qualifications/type#new', as: :new_other_qualification_type
        post '/' => 'other_qualifications/type#create', as: :create_other_qualification_type

        get '/edit-type/:id' => 'other_qualifications/type#edit', as: :edit_other_qualification_type
        post '/edit-type/:id' => 'other_qualifications/type#update'

        get '/new/:id' => 'other_qualifications/details#new', as: :new_other_qualification_details
        post '/new/:id' => 'other_qualifications/details#create', as: :create_other_qualification_details

        get '/edit-details/:id' => 'other_qualifications/details#edit', as: :edit_other_qualification_details
        post '/edit-details/:id' => 'other_qualifications/details#update'

        get '/review' => 'other_qualifications/review#show', as: :review_other_qualifications
        patch '/review' => 'other_qualifications/review#complete', as: :complete_other_qualifications

        get '/delete/:id' => 'other_qualifications/destroy#confirm_destroy', as: :confirm_destroy_other_qualification
        delete '/delete/:id' => 'other_qualifications/destroy#destroy'
      end

      scope '/english-as-a-foreign-language' do
        get '/' => 'english_foreign_language/start#new', as: :english_foreign_language_start
        post '/' => 'english_foreign_language/start#create'
        get '/proficiency/edit' => 'english_foreign_language/start#edit', as: :english_foreign_language_edit_start
        patch '/proficiency/edit' => 'english_foreign_language/start#update'

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

      scope '/referees' do
        get '/' => 'referees#index', as: :referees

        get '/type/(:id)' => 'referees#type', as: :referees_type
        post '/update-type/(:id)' => 'referees#update_type', as: :update_referees_type

        get '/new/(:type)' => 'referees#new', as: :new_referee, constraints: { type: Regexp.new(ApplicationReference.referee_types.values.join('|')) }
        post '/(:type)' => 'referees#create'

        get '/review' => 'referees#review', as: :review_referees
        patch '/complete' => 'referees#complete', as: :complete_referees

        get '/edit/:id' => 'referees#edit', as: :edit_referee
        patch '/update/:id' => 'referees#update', as: :update_referee

        get '/delete/:id' => 'referees#confirm_destroy', as: :confirm_destroy_referee
        delete '/delete/:id' => 'referees#destroy', as: :destroy_referee

        get '/cancel/:id' => 'referees#confirm_cancel', as: :confirm_cancel_referee
        patch '/cancel/:id' => 'referees#cancel', as: :cancel_referee
      end

      scope '/new-referee' do
        get '/' => 'additional_referees#show', as: :additional_referee

        get '/type/(:id)' => 'additional_referees#type', as: :additional_referee_type
        post '/type/(:id)' => 'additional_referees#type'
        post '/update-type/(:id)' => 'additional_referees#update_type', as: :update_additional_referee_type

        get '/new' => 'additional_referees#new', as: :new_additional_referee, constraints: ->(request) { request.query_parameters['type'] =~ Regexp.new(ApplicationReference.referee_types.values.join('|')) }
        post '/new' => 'additional_referees#create'

        get '/:application_reference_id/edit' => 'additional_referees#edit', as: :edit_additional_referee
        patch '/:application_reference_id/edit' => 'additional_referees#update'

        get '/confirm' => 'additional_referees#confirm', as: :confirm_additional_referees
        post '/confirm' => 'additional_referees#request_references'

        get '/add-another-referee' => 'additional_referees#add_another_referee', as: :add_another_referee
        post '/add-another-referee' => 'additional_referees#add_another_referee_decision'

        get '/contact-support' => 'additional_referees#contact_support', as: :additional_referee_contact_support
      end

      scope '/equality-and-diversity' do
        get '/' => 'equality_and_diversity#start', as: :start_equality_and_diversity
        get '/sex' => 'equality_and_diversity#edit_sex', as: :edit_equality_and_diversity_sex
        post '/sex' => 'equality_and_diversity#update_sex', as: :update_equality_and_diversity_sex
        get '/disability-status' => 'equality_and_diversity#edit_disability_status', as: :edit_equality_and_diversity_disability_status
        post '/disability-status' => 'equality_and_diversity#update_disability_status', as: :update_equality_and_diversity_disability_status
        get '/disabilities' => 'equality_and_diversity#edit_disabilities', as: :edit_equality_and_diversity_disabilities
        post '/disabilities' => 'equality_and_diversity#update_disabilities', as: :update_equality_and_diversity_disabilities
        get '/ethnic-group' => 'equality_and_diversity#edit_ethnic_group', as: :edit_equality_and_diversity_ethnic_group
        post '/ethnic-group' => 'equality_and_diversity#update_ethnic_group', as: :update_equality_and_diversity_ethnic_group
        get '/ethnic-background' => 'equality_and_diversity#edit_ethnic_background', as: :edit_equality_and_diversity_ethnic_background
        post '/ethnic-background' => 'equality_and_diversity#update_ethnic_background', as: :update_equality_and_diversity_ethnic_background
        get '/review' => 'equality_and_diversity#review', as: :review_equality_and_diversity
      end

      scope '/safeguarding' do
        get '/' => 'safeguarding#edit', as: :edit_safeguarding
        post '/' => 'safeguarding#update'
        get '/review' => 'safeguarding#show', as: :review_safeguarding
        post '/complete' => 'safeguarding#complete', as: :complete_safeguarding
      end

      scope '/satisfaction-survey' do
        get '/recommendation' => 'satisfaction_survey#recommendation', as: :satisfaction_survey_recommendation
        post '/recommendation' => 'satisfaction_survey#submit_recommendation', as: :satisfaction_survey_submit_recommendation

        get '/complexity' => 'satisfaction_survey#complexity', as: :satisfaction_survey_complexity
        post '/complexity' => 'satisfaction_survey#submit_complexity', as: :satisfaction_survey_submit_complexity

        get '/ease-of-use' => 'satisfaction_survey#ease_of_use', as: :satisfaction_survey_ease_of_use
        post '/ease-of-use' => 'satisfaction_survey#submit_ease_of_use', as: :satisfaction_survey_submit_ease_of_use

        get '/help-needed' => 'satisfaction_survey#help_needed', as: :satisfaction_survey_help_needed
        post '/help-needed' => 'satisfaction_survey#submit_help_needed', as: :satisfaction_survey_submit_help_needed

        get '/organisation' => 'satisfaction_survey#organisation', as: :satisfaction_survey_organisation
        post '/organisation' => 'satisfaction_survey#submit_organisation', as: :satisfaction_survey_submit_organisation

        get '/consistency' => 'satisfaction_survey#consistency', as: :satisfaction_survey_consistency
        post '/consistency' => 'satisfaction_survey#submit_consistency', as: :satisfaction_survey_submit_consistency

        get '/adaptability' => 'satisfaction_survey#adaptability', as: :satisfaction_survey_adaptability
        post '/adaptability' => 'satisfaction_survey#submit_adaptability', as: :satisfaction_survey_submit_adaptability

        get '/awkward' => 'satisfaction_survey#awkward', as: :satisfaction_survey_awkward
        post '/awkward' => 'satisfaction_survey#submit_awkward', as: :satisfaction_survey_submit_awkward

        get '/confidence' => 'satisfaction_survey#confidence', as: :satisfaction_survey_confidence
        post '/confidence' => 'satisfaction_survey#submit_confidence', as: :satisfaction_survey_submit_confidence

        get '/needed-additional-learning' => 'satisfaction_survey#needed_additional_learning', as: :satisfaction_survey_needed_additional_learning
        post '/needed-additional-learning' => 'satisfaction_survey#submit_needed_additional_learning', as: :satisfaction_survey_submit_needed_additional_learning

        get '/improvements' => 'satisfaction_survey#improvements', as: :satisfaction_survey_improvements
        post '/improvements' => 'satisfaction_survey#submit_improvements', as: :satisfaction_survey_submit_improvements

        get '/other-information' => 'satisfaction_survey#other_information', as: :satisfaction_survey_other_information
        post '/other-information' => 'satisfaction_survey#submit_other_information', as: :satisfaction_survey_submit_other_information

        get '/contact' => 'satisfaction_survey#contact', as: :satisfaction_survey_contact
        post '/contact' => 'satisfaction_survey#submit_contact', as: :satisfaction_survey_submit_contact

        get '/thank-you' => 'satisfaction_survey#thank_you', as: :satisfaction_survey_thank_you
      end
    end
  end

  namespace :referee_interface, path: '/reference' do
    get '/' => 'reference#relationship', as: :reference_relationship
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

    get '/refuse-feedback' => 'reference#refuse_feedback', as: :refuse_feedback
    patch '/refuse-feedback' => 'reference#confirm_feedback_refusal'
  end

  namespace :vendor_api, path: 'api/v1' do
    get '/applications' => 'applications#index'
    get '/applications/:application_id' => 'applications#show'

    scope path: '/applications/:application_id' do
      post '/offer' => 'decisions#make_offer'
      post '/confirm-conditions-met' => 'decisions#confirm_conditions_met'
      post '/conditions-not-met' => 'decisions#conditions_not_met'
      post '/reject' => 'decisions#reject'
      post '/confirm-enrolment' => 'decisions#confirm_enrolment'
    end

    post '/test-data/regenerate' => 'test_data#regenerate'
    post '/test-data/generate' => 'test_data#generate'
    post '/test-data/clear' => 'test_data#clear!'

    post '/experimental/test-data/generate' => 'test_data#experimental_endpoint_moved'
    post '/experimental/test-data/clear' => 'test_data#experimental_endpoint_moved'

    get '/ping', to: 'ping#ping'
  end

  namespace :provider_interface, path: '/provider' do
    get '/' => 'start_page#show'

    get '/accessibility', to: 'content#accessibility'
    get '/privacy-policy', to: 'content#privacy_policy', as: :privacy_policy
    get '/cookies', to: 'content#cookies_provider', as: :cookies
    get '/service-guidance', to: 'content#service_guidance_provider', as: :service_guidance
    get '/covid-19-guidance', to: 'content#covid_19_guidance', as: :covid_19_guidance
    get '/getting-ready-for-next-cycle', to: 'content#getting_ready_for_next_cycle', as: :getting_ready_for_next_cycle

    get '/data-sharing-agreements/new', to: 'provider_agreements#new_data_sharing_agreement', as: :new_data_sharing_agreement
    post '/data-sharing-agreements', to: 'provider_agreements#create_data_sharing_agreement', as: :create_data_sharing_agreement

    get '/applications' => 'application_choices#index'

    scope path: '/applications/:application_choice_id' do
      get '/' => 'application_choices#show', as: :application_choice
      get '/notes' => 'application_choices#notes', as: :application_choice_notes
      get '/notes/new' => 'application_choices#new_note', as: :application_choice_new_note
      post '/notes' => 'application_choices#create_note', as: :application_choice_create_note
      get '/timeline' => 'application_choices#timeline', as: :application_choice_timeline
      get '/emails' => 'application_choices#emails', as: :application_choice_emails
      get '/respond' => 'decisions#respond', as: :application_choice_respond
      post '/respond' => 'decisions#submit_response', as: :application_choice_submit_response
      get '/offer' => 'decisions#new_offer', as: :application_choice_new_offer
      get '/reject' => 'decisions#new_reject', as: :application_choice_new_reject
      post '/reject/confirm' => 'decisions#confirm_reject', as: :application_choice_confirm_reject
      post '/reject' => 'decisions#create_reject', as: :application_choice_create_reject
      post '/offer/confirm' => 'decisions#confirm_offer', as: :application_choice_confirm_offer
      post '/offer' => 'decisions#create_offer', as: :application_choice_create_offer
      get '/conditions' => 'conditions#edit', as: :application_choice_edit_conditions
      patch '/conditions/confirm' => 'conditions#confirm_update', as: :application_choice_confirm_update_conditions
      patch '/conditions' => 'conditions#update', as: :application_choice_update_conditions
      get '/offer/change/*step' => 'offer_changes#edit_offer', as: :application_choice_edit_offer
      patch '/offer/change' => 'offer_changes#update_offer', as: :application_choice_update_offer
      get '/offer/new_withdraw' => 'decisions#new_withdraw_offer', as: :application_choice_new_withdraw_offer
      post '/offer/confirm_withdraw' => 'decisions#confirm_withdraw_offer', as: :application_choice_confirm_withdraw_offer
      post '/offer/withdraw' => 'decisions#withdraw_offer', as: :application_choice_withdraw_offer
    end

    post '/candidates/:candidate_id/impersonate' => 'candidates#impersonate', as: :impersonate_candidate

    get '/account' => 'account#show'
    get '/sign-in' => 'sessions#new'
    get '/sign-out' => 'sessions#destroy'

    post '/request-sign-in-by-email' => 'sessions#sign_in_by_email', as: :sign_in_by_email
    get '/sign-in/check-email', to: 'sessions#check_your_email', as: :check_your_email
    get '/sign-in-by-email' => 'sessions#authenticate_with_token', as: :authenticate_with_token

    scope path: '/users' do
      get '/' => 'provider_users#index', as: :provider_users

      get '/new' => 'provider_users_invitations#edit_details', as: :edit_invitation_basic_details
      post '/new' => 'provider_users_invitations#update_details', as: :update_invitation_basic_details
      get '/new/providers' => 'provider_users_invitations#edit_providers', as: :edit_invitation_providers
      post '/new/providers' => 'provider_users_invitations#update_providers', as: :update_invitation_providers
      get '/new/providers/:provider_id/permissions' => 'provider_users_invitations#edit_permissions', as: :edit_invitation_provider_permissions
      post '/new/providers/:provider_id/permissions' => 'provider_users_invitations#update_permissions', as: :update_invitation_provider_permissions
      get '/new/check' => 'provider_users_invitations#check', as: :check_invitation
      post '/new/commit' => 'provider_users_invitations#commit', as: :commit_invitation

      scope '/:provider_user_id', as: :provider_user do
        get '/' => 'provider_users#show'

        get '/edit-providers' => 'provider_users#edit_providers', as: :edit_providers
        patch '/edit-providers' => 'provider_users#update_providers'

        get '/remove' => 'provider_users#confirm_remove', as: :remove_provider_user
        delete '/remove' => 'provider_users#remove'

        get '/providers/:provider_id/permissions' => 'provider_users#edit_permissions', as: :edit_permissions
        patch '/providers/:provider_id/permissions' => 'provider_users#update_permissions'
      end
    end

    resources :organisations, only: %i[index show], path: 'organisations'

    scope path: '/provider-relationship-permissions' do
      get '/organisations-to-setup' => 'provider_relationship_permissions_setup#organisations',
          as: :provider_relationship_permissions_organisations
      get '/information' => 'provider_relationship_permissions_setup#info',
          as: :provider_relationship_permissions_info
      get '/:id/setup' => 'provider_relationship_permissions_setup#setup_permissions',
          as: :setup_provider_relationship_permissions
      post '/:id/create' => 'provider_relationship_permissions_setup#save_permissions',
           as: :save_provider_relationship_permissions
      get '/check' => 'provider_relationship_permissions_setup#check',
          as: :check_provider_relationship_permissions
      post '/commit' => 'provider_relationship_permissions_setup#commit',
           as: :commit_provider_relationship_permissions
      get '/success' => 'provider_relationship_permissions_setup#success',
          as: :provider_relationship_permissions_success

      get '/:id/edit' => 'provider_relationship_permissions#edit',
          as: :edit_provider_relationship_permissions
      patch '/:id' => 'provider_relationship_permissions#update',
            as: :update_provider_relationship_permissions
    end
  end

  get '/auth/dfe/callback' => 'dfe_sign_in#callback'
  post '/auth/developer/callback' => 'dfe_sign_in#bypass_callback'
  get '/auth/dfe/sign-out' => 'dfe_sign_in#redirect_after_dsi_signout'

  namespace :integrations, path: '/integrations' do
    post '/notify/callback' => 'notify#callback'
    get '/feature-flags' => 'feature_flags#index'
    get '/performance-dashboard' => 'performance_dashboard#dashboard', as: :performance
  end

  namespace :support_interface, path: '/support' do
    get '/' => redirect('/support/candidates')

    get '/provider-flow', to: 'docs#provider_flow', as: :provider_flow
    get '/candidate-flow', to: 'docs#candidate_flow', as: :candidate_flow
    get '/when-emails-are-sent', to: 'docs#when_emails_are_sent', as: :when_emails_are_sent

    get '/email-log', to: 'email_log#index', as: :email_log

    get '/applications' => 'application_forms#index'
    get '/applications/unavailable-choices' => 'application_forms#unavailable_choices', as: :unavailable_choices

    scope path: '/applications/:application_form_id' do
      get '/' => 'application_forms#show', as: :application_form
      get '/audit' => 'application_forms#audit', as: :application_form_audit
      get '/comments/new' => 'application_forms/comments#new', as: :application_form_new_comment
      post '/comments' => 'application_forms/comments#create', as: :application_form_comments
    end

    get '/application_choices/:application_choice_id' => 'application_choices#show', as: :application_choice

    scope path: '/applications/:application_form_id' do
      get '/change-course' => 'change_course#options', as: :change_course
      post '/change-course' => 'change_course#pick_option'
      get '/change-course/add-choice' => 'change_course#select_course_to_add', as: :add_course_to_application
      post '/change-course/add-choice' => 'change_course#add_choice'
      get '/change-course/withdraw-choice' => 'change_course#select_choice_to_withdraw', as: :withdraw_choice
      post '/change-course/withdraw-choice' => 'change_course#withdraw_choice'
      get '/change-course/cancel-application' => 'change_course#confirm_cancel_application', as: :cancel_application
      post '/change-course/cancel-application' => 'change_course#cancel_application'
    end

    get '/candidates' => 'candidates#index'

    scope path: '/candidates/:candidate_id' do
      get '/' => 'candidates#show', as: :candidate
      post '/hide' => 'candidates#hide_in_reporting', as: :hide_candidate
      post '/show' => 'candidates#show_in_reporting', as: :show_candidate
      post '/impersonate' => 'candidates#impersonate', as: :impersonate_candidate
    end

    get '/send-survey-email/:application_form_id' => 'survey_emails#show', as: :survey_emails
    post '/send-survey-email/:application_form_id' => 'survey_emails#deliver'

    scope path: '/references/:reference_id' do
      get '/cancel' => 'references#cancel', as: :cancel_reference
      post '/cancel' => 'references#confirm_cancel'
      get '/reinstate' => 'references#reinstate', as: :reinstate_reference
      post '/reinstate' => 'references#confirm_reinstate'
    end

    get '/tokens' => 'api_tokens#index', as: :api_tokens
    post '/tokens' => 'api_tokens#create'

    get '/providers' => 'providers#index', as: :providers
    get '/providers/other' => 'providers#other_providers', as: :other_providers

    scope path: '/providers/:provider_id' do
      get '/' => 'providers#show', as: :provider
      get '/courses' => 'providers#courses', as: :provider_courses
      get '/vacancies' => 'providers#vacancies', as: :provider_vacancies
      get '/sites' => 'providers#sites', as: :provider_sites
      get '/users' => 'providers#users', as: :provider_user_list
      get '/applications' => 'providers#applications', as: :provider_applications
      get '/history' => 'providers#history', as: :provider_history

      post '' => 'providers#open_all_courses'
      post '/enable_course_syncing' => 'providers#enable_course_syncing', as: :enable_provider_course_syncing
    end

    get '/course-options' => 'course_options#index', as: :course_options

    get '/courses/:course_id' => 'courses#show', as: :course
    post '/courses/:course_id' => 'courses#update'

    get '/feature-flags' => 'feature_flags#index', as: :feature_flags
    post '/feature-flags/:feature_name/activate' => 'feature_flags#activate', as: :activate_feature_flag
    post '/feature-flags/:feature_name/deactivate' => 'feature_flags#deactivate', as: :deactivate_feature_flag

    get '/performance' => 'performance#index', as: :performance
    get '/performance/application-timings', to: 'performance#application_timings', as: :application_timings
    get '/performance/submitted-application-choices', to: 'performance#submitted_application_choices', as: :submitted_application_choices
    get '/performance/referee-survey', to: 'performance#referee_survey', as: :referee_survey
    get '/performance/providers', to: 'performance#providers_export', as: :providers_export
    get '/performance/candidate-survey', to: 'performance#candidate_survey', as: :candidate_survey
    get '/performance/active-provider-users', to: 'performance#active_provider_users', as: :active_provider_users
    get '/performance/tad-provider-performance', to: 'performance#tad_provider_performance', as: :tad_provider_performance
    get '/performance/course-choice-withdrawal', to: 'performance#course_choice_withdrawal', as: :course_choice_withdrawal_survey
    get '/performance/candidate-journey-tracking', to: 'performance#candidate_journey_tracking', as: :candidate_journey_tracking

    get '/tasks' => 'tasks#index', as: :tasks
    post '/tasks/create-fake-provider' => 'tasks#create_fake_provider'
    post '/tasks/:task' => 'tasks#run', as: :run_task
    get '/tasks/confirm_delete_test_applications' => 'tasks#confirm_delete_test_applications', as: :confirm_delete_test_applications

    get '/validation-errors' => 'validation_errors#index', as: :validation_errors
    get '/validation-errors/search' => 'validation_errors#search', as: :validation_error_search
    get '/validation-errors/summary' => 'validation_errors#summary', as: :validation_error_summary

    scope '/users' do
      get '/' => 'users#index', as: :users

      get '/delete/:id' => 'support_users#confirm_destroy', as: :confirm_destroy_support_user
      delete '/delete/:id' => 'support_users#destroy', as: :destroy_support_user
      get '/restore/:id' => 'support_users#confirm_restore', as: :confirm_restore_support_user
      delete '/restore/:id' => 'support_users#restore', as: :restore_support_user

      resources :support_users, only: %i[index new create show], path: :support

      resources :provider_users, only: %i[index new create edit update], path: :provider do
        get '/audits' => 'provider_users#audits'
      end
    end

    get '/guidance' => 'guidance#index', as: :guidance

    get '/sign-in' => 'sessions#new'
    get '/sign-out' => 'sessions#destroy'

    post '/request-sign-in-by-email' => 'sessions#sign_in_by_email', as: :sign_in_by_email
    get '/sign-in/check-email', to: 'sessions#check_your_email', as: :check_your_email
    get '/sign-in-by-email' => 'sessions#authenticate_with_token', as: :authenticate_with_token

    get '/mailers' => 'mailer_previews#index'

    # https://github.com/mperham/sidekiq/wiki/Monitoring#rails-http-basic-auth-from-routes
    require 'sidekiq/web'
    require 'support_user_constraint'

    mount Sidekiq::Web => '/sidekiq', constraints: SupportUserConstraint.new
    get '/sidekiq', to: redirect('/support/sign-in'), status: 302
  end

  namespace :api_docs, path: '/api-docs' do
    get '/' => 'pages#home', as: :home
    get '/usage-scenarios' => 'pages#usage', as: :usage
    get '/reference' => 'reference#reference', as: :reference
    get '/release-notes' => 'pages#release_notes', as: :release_notes
    get '/alpha-release-notes' => 'pages#alpha_release_notes'
    get '/lifecycle' => 'pages#lifecycle'
    get '/when-emails-are-sent' => 'pages#when_emails_are_sent'
    get '/help' => 'pages#help', as: :help
    get '/spec.yml' => 'openapi#spec', as: :spec
  end

  get '/check', to: 'healthcheck#show'

  scope via: :all do
    match '/404', to: 'errors#not_found'
    match '/406', to: 'errors#not_acceptable'
    match '/422', to: 'errors#unprocessable_entity'
    match '/500', to: 'errors#internal_server_error'
  end

  get '*path', to: 'errors#not_found'
end
