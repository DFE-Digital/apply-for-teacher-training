class CandidateInterfaceRoutes < RouteExtension
  def routes
    get '/' => 'start_page#show', as: :start

    get '/accessibility', to: 'content#accessibility'
    get '/privacy-policy', to: 'content#privacy_policy', as: :privacy_policy
    get '/cookies', to: 'content#cookies_candidate', as: :cookies
    get '/terms-of-use', to: 'content#terms_candidate', as: :terms
    get '/providers', to: 'content#providers', as: :providers

    get '/eligibility' => 'start_page#eligibility', as: :eligibility
    post '/eligibility' => 'start_page#determine_eligibility'
    get '/not-eligible', to: 'start_page#not_eligible', as: :not_eligible

    get '/sign-up', to: 'sign_up#new', as: :sign_up
    post '/sign-up', to: 'sign_up#create'
    get '/sign-up/check-email', to: 'sign_in#check_your_email', as: :check_email_sign_up

    get '/sign-in', to: 'sign_in#new', as: :sign_in
    post '/sign-in', to: 'sign_in#create'
    get '/sign-in/check-email', to: 'sign_in#check_your_email', as: :check_email_sign_in

    get '/authenticate', to: 'sign_in#authenticate', as: :authenticate

    get '/apply', to: 'apply_from_find#show', as: :apply_from_find

    scope '/application' do
      get '/' => 'application_form#show', as: :application_form
      get '/edit' => 'application_form#edit', as: :application_edit
      get '/review' => 'application_form#review', as: :application_review
      get '/review/submitted' => 'application_form#review_submitted', as: :application_review_submitted
      get '/complete' => 'application_form#complete', as: :application_complete
      get '/submit' => 'application_form#submit_show', as: :application_submit_show
      post '/submit' => 'application_form#submit', as: :application_submit
      get '/submit-success' => 'application_form#submit_success', as: :application_submit_success

      scope '/personal-details' do
        get '/' => 'personal_details#edit', as: :personal_details_edit
        post '/review' => 'personal_details#update', as: :personal_details_update
        get '/review' => 'personal_details#show', as: :personal_details_show
      end

      scope '/personal-statement' do
        get '/becoming-a-teacher' => 'personal_statement/becoming_a_teacher#edit', as: :becoming_a_teacher_edit
        post '/becoming-a-teacher/review' => 'personal_statement/becoming_a_teacher#update', as: :becoming_a_teacher_update
        get '/becoming-a-teacher/review' => 'personal_statement/becoming_a_teacher#show', as: :becoming_a_teacher_show

        get '/subject-knowledge' => 'personal_statement/subject_knowledge#edit', as: :subject_knowledge_edit
        post '/subject-knowledge/review' => 'personal_statement/subject_knowledge#update', as: :subject_knowledge_update
        get '/subject-knowledge/review' => 'personal_statement/subject_knowledge#show', as: :subject_knowledge_show

        get '/interview-preferences' => 'personal_statement/interview_preferences#edit', as: :interview_preferences_edit
        post '/interview-preferences/review' => 'personal_statement/interview_preferences#update', as: :interview_preferences_update
        get '/interview-preferences/review' => 'personal_statement/interview_preferences#show', as: :interview_preferences_show
      end

      scope '/training-with-a-disability' do
        get '/' => 'training_with_a_disability#edit', as: :training_with_a_disability_edit
        post '/review' => 'training_with_a_disability#update', as: :training_with_a_disability_update
        get '/review' => 'training_with_a_disability#show', as: :training_with_a_disability_show
      end

      scope '/contact-details' do
        get '/' => 'contact_details/base#edit', as: :contact_details_edit_base
        post '/' => 'contact_details/base#update', as: :contact_details_update_base

        get '/address' => 'contact_details/address#edit', as: :contact_details_edit_address
        post '/address' => 'contact_details/address#update', as: :contact_details_update_address

        get '/review' => 'contact_details/review#show', as: :contact_details_review
      end

      scope '/gcse/:subject', constraints: { subject: /(maths|english|science)/ } do
        get '/' => 'gcse/type#edit', as: :gcse_details_edit_type
        post '/' => 'gcse/type#update', as: :gcse_details_update_type

        get '/grade' => 'gcse/grade#edit', as: :gcse_details_edit_grade
        patch '/grade' => 'gcse/grade#update', as: :gcse_details_update_grade

        get '/year' => 'gcse/year#edit', as: :gcse_details_edit_year
        patch '/year' => 'gcse/year#update', as: :gcse_details_update_year

        get '/review' => 'gcse/review#show', as: :gcse_review
      end

      scope '/work-history' do
        get '/length' => 'work_history/length#show', as: :work_history_length
        post '/length' => 'work_history/length#submit'

        get '/missing' => 'work_history/explanation#show', as: :work_history_explanation
        post '/missing' => 'work_history/explanation#submit'

        get '/explain-breaks' => 'work_history/breaks#edit', as: :work_history_breaks
        post '/explain-breaks' => 'work_history/breaks#update'

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
        get '/' => 'degrees/base#new', as: :degrees_new_base
        post '/' => 'degrees/base#create', as: :degrees_create_base

        get '/:id/grade' => 'degrees/grade#new', as: :degrees_grade
        get '/:id/grade/edit' => 'degrees/grade#edit', as: :degrees_grade_edit
        post '/:id/grade' => 'degrees/grade#update', as: :degrees_create_grade

        get '/:id/year' => 'degrees/year#new', as: :degrees_year
        get '/:id/year/edit' => 'degrees/year#edit', as: :degrees_year_edit
        post '/:id/year' => 'degrees/year#update', as: :degrees_create_year

        get '/review' => 'degrees/review#show', as: :degrees_review
        patch '/review' => 'degrees/review#complete', as: :degrees_complete

        get '/edit/:id' => 'degrees/base#edit', as: :degrees_edit
        post '/edit/:id' => 'degrees/base#update'

        get '/delete/:id' => 'degrees/destroy#confirm_destroy', as: :confirm_degrees_destroy
        delete '/delete/:id' => 'degrees/destroy#destroy'
      end

      scope '/courses' do
        get '/' => 'course_choices#index', as: :course_choices_index

        get '/choose' => 'course_choices#have_you_chosen', as: :course_choices_choose
        post '/choose' => 'course_choices#make_choice'

        get '/delete/:id' => 'course_choices#confirm_destroy', as: :confirm_destroy_course_choice
        delete '/delete/:id' => 'course_choices#destroy'

        get '/provider' => 'course_choices#options_for_provider', as: :course_choices_provider
        post '/provider' => 'course_choices#pick_provider'

        get '/apply-on-ucas' => 'course_choices#ucas', as: :course_choices_on_ucas

        get '/provider/:provider_code/courses' => 'course_choices#options_for_course', as: :course_choices_course
        post '/provider/:provider_code/courses' => 'course_choices#pick_course'

        get '/provider/:provider_code/courses/:course_code' => 'course_choices#options_for_site', as: :course_choices_site
        post '/provider/:provider_code/courses/:course_code' => 'course_choices#pick_site'

        get '/review' => 'course_choices#review', as: :course_choices_review
        patch '/review' => 'course_choices#complete', as: :course_choices_complete
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
      end

      scope '/other-qualifications' do
        get '/' => 'other_qualifications/base#new', as: :new_other_qualification
        post '/' => 'other_qualifications/base#create', as: :create_other_qualification

        get '/review' => 'other_qualifications/review#show', as: :review_other_qualifications
        patch '/review' => 'other_qualifications/review#complete', as: :complete_other_qualifications

        get '/edit/:id' => 'other_qualifications/base#edit', as: :edit_other_qualification
        post '/edit/:id' => 'other_qualifications/base#update'

        get '/delete/:id' => 'other_qualifications/destroy#confirm_destroy', as: :confirm_destroy_other_qualification
        delete '/delete/:id' => 'other_qualifications/destroy#destroy'
      end

      scope '/referees' do
        get '/' => 'referees#index', as: :referees
        get '/new' => 'referees#new', as: :new_referee
        post '/' => 'referees#create'

        get '/review' => 'referees#review', as: :review_referees
        patch '/review' => 'referees#complete', as: :complete_referees

        get '/edit/:id' => 'referees#edit', as: :edit_referee
        patch '/update/:id' => 'referees#update', as: :update_referee

        get '/delete/:id' => 'referees#confirm_destroy', as: :confirm_destroy_referee
        delete '/delete/:id' => 'referees#destroy', as: :destroy_referee
      end
    end
  end
end
