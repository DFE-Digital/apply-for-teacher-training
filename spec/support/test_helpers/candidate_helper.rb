module CandidateHelper
  APPLICATION_FORM_SECTIONS = %i[
    course_choices
    personal_details
    contact_details
    training_with_a_disability
    safeguarding
    work_experience
    volunteering
    degrees
    maths_gcse
    english_gcse
    science_gcse
    efl
    becoming_a_teacher
    interview_preferences
    references_selected
    equality_and_diversity
  ].freeze

  def create_and_sign_in_candidate(candidate: current_candidate)
    login_as(candidate)
  end

  def application_form_sections
    APPLICATION_FORM_SECTIONS
  end

  def candidate_completes_application_form(with_referees: true, international: false, candidate: current_candidate)
    given_courses_exist
    create_and_sign_in_candidate(candidate:)

    ##########################################
    #
    # Filling out Your Details
    #
    ##########################################

    visit candidate_interface_details_path

    click_link_or_button t('page_titles.personal_information.heading')
    candidate_fills_in_personal_details(international:)

    click_link_or_button t('page_titles.contact_information')
    candidate_fills_in_contact_details

    click_link_or_button t('page_titles.work_history')

    candidate_fills_in_restructured_work_experience
    candidate_fills_in_restructured_work_experience_break

    if with_referees
      candidate_provides_two_referees
      receive_references
      advance_time_to(5.minutes.from_now)
      mark_references_as_complete
    end

    click_link_or_button t('page_titles.volunteering.short')

    candidate_fills_in_restructured_volunteering_role

    click_link_or_button t('page_titles.training_with_a_disability')
    candidate_fills_in_disability_info

    click_link_or_button t('page_titles.suitability_to_work_with_children')
    candidate_fills_in_safeguarding_issues

    click_link_or_button t('page_titles.degree')
    candidate_fills_in_their_degree

    click_link_or_button 'Maths GCSE or equivalent'
    candidate_fills_in_their_maths_gcse

    click_link_or_button 'English GCSE or equivalent'
    candidate_fills_in_their_english_gcse

    click_link_or_button(international ? 'Other qualifications' : 'A levels and other qualifications')
    candidate_fills_in_their_other_qualifications

    click_link_or_button t('application_form.personal_statement.label')
    candidate_fills_in_personal_statement

    click_link_or_button t('page_titles.interview_preferences.heading')
    candidate_fills_in_interview_preferences

    click_link_or_button 'Equality and diversity questions'
    if international
      candidate_fills_in_diversity_information(school_meals: false)
    else
      candidate_fills_in_diversity_information
    end

    if international
      click_link_or_button 'English as a foreign language'
      choose 'No, English is not a foreign language to me'
      click_link_or_button 'Continue'
      choose 'Yes, I have completed this section'
      click_link_or_button 'Continue'
    end

    ##########################################
    #
    # Filling out Your Applications
    #
    ##########################################

    visit candidate_interface_application_choices_path
    click_link_or_button 'Add application'
    choose 'Yes, I know where I want to apply'
    click_link_or_button t('continue')

    select 'Gorse SCITT (1N1)'
    click_link_or_button t('continue')

    choose 'Primary (2XT2)'
    click_link_or_button t('continue')

    ###############################################
    #
    # Return to details to fill out Science GCSE
    #
    ###############################################

    visit candidate_interface_details_path

    click_link_or_button 'Science GCSE or equivalent'
    candidate_explains_a_missing_gcse

    @application = ApplicationForm.last
  end

  def candidate_submits_application
    visit candidate_interface_application_choices_path

    click_link_or_button 'Gorse SCITT'
    click_link_or_button 'Review application'
    click_link_or_button 'Continue without editing'
    click_link_or_button 'Confirm and submit application'

    @application = ApplicationForm.last
  end

  def candidate_fills_in_diversity_information(school_meals: true, complete_section: true)
    # Equality and diversity questions

    # What is your sex?
    choose 'Prefer not to say'
    click_link_or_button t('continue')

    # Are you disabled?
    check 'Prefer not to say'
    click_link_or_button t('continue')

    # What is your ethnic group?
    choose 'Prefer not to say'
    click_link_or_button t('continue')

    if school_meals
      # Did you ever get free school meals in the UK?
      choose 'Prefer not to say'
      click_link_or_button t('continue')
    end

    # Review page
    if complete_section
      choose 'Yes, I have completed this section'
    else
      choose 'No, I’ll come back to it later'
    end
    click_link_or_button t('save_changes_and_return')
  end

  def receive_references
    application_form = ApplicationForm.last
    first_reference = application_form.application_references.creation_order.first

    first_reference.update!(
      feedback: 'My ideal person',
      relationship_correction: '',
      safeguarding_concerns: '',
    )

    SubmitReference.new(
      reference: first_reference,
    ).save!

    second_reference = application_form.application_references.creation_order.second

    second_reference.update!(
      feedback: 'Lovable',
      relationship_correction: '',
      safeguarding_concerns: '',
    )

    SubmitReference.new(
      reference: second_reference,
    ).save!
  end

  def mark_references_as_complete
    visit candidate_interface_details_path

    click_link_or_button 'References to be requested if you accept an offer'

    choose 'Yes, I have completed this section'
    click_link_or_button t('save_changes_and_return')
  end

  def given_courses_exist
    @provider = Provider.find_by(code: '1N1') || create(:provider, name: 'Gorse SCITT', code: '1N1', provider_type: 'scitt')
    site = create(:site, name: 'Main site', code: '-', provider: @provider, uuid: '9ad872fe-9461-4db6-a82a-f24b9a651bf2')
    course =
      Course.find_by(code: '2XT2', provider: @provider) ||
      create(:course, :open, name: 'Primary', code: '2XT2', provider: @provider, start_date: Date.new(2020, 9, 1), level: :primary)
    course2 =
      Course.find_by(code: '2397', provider: @provider) ||
      create(:course, :open, name: 'Drama', level: 'secondary', code: '2397', provider: @provider, start_date: Date.new(2020, 9, 1))
    course3 =
      Course.find_by(code: '6Z9H', provider: @provider) ||
      create(:course, :open, name: 'English', level: 'secondary', code: '6Z9H', provider: @provider, start_date: Date.new(2020, 9, 1))
    course4 =
      Course.find_by(code: '2392', provider: @provider) ||
      create(:course, :open, name: 'Biology', level: 'secondary', code: '2392', provider: @provider, start_date: Date.new(2020, 9, 1))
    create(:course_option, site:, course:) unless CourseOption.find_by(site:, course:, study_mode: :full_time)
    create(:course_option, site:, course: course2) unless CourseOption.find_by(site:, course: course2, study_mode: :full_time)
    create(:course_option, site:, course: course3) unless CourseOption.find_by(site:, course: course3, study_mode: :full_time)
    create(:course_option, site:, course: course4) unless CourseOption.find_by(site:, course: course4, study_mode: :full_time)
  end

  def given_undergraduate_courses_exist
    @provider = create(:provider, name: 'Gorse SCITT', code: '1N1', provider_type: 'scitt')
    site = create(:site, name: 'Main site', code: '-', provider: @provider)
    @course = create(
      :course,
      :teacher_degree_apprenticeship,
      :open,
      :secondary,
      name: 'Mathematics',
      code: 'VTDR',
      provider: @provider,
    )
    create(:course_option, site:, course: @course)
  end

  def candidate_fills_in_apply_again_course_choice
    visit candidate_interface_application_choices_path
    click_link_or_button 'Add application'

    choose 'Yes, I know where I want to apply'
    click_link_or_button t('continue')

    select 'Gorse SCITT (1N1)'
    click_link_or_button t('continue')

    choose 'Primary (2XT2)'
    click_link_or_button t('continue')

    choose t('application_form.completed_radio')
    click_link_or_button t('save_changes_and_return')
  end

  def candidate_does_not_have_a_degree
    @application.application_qualifications.degrees.delete_all
    @application.update!(degrees_completed: false)
    visit candidate_interface_details_path
    click_link_or_button 'Degree'
    choose 'No, I do not have a degree'
    click_link_or_button 'Continue'
  end

  def candidate_submits_undergraduate_application
    visit candidate_interface_application_choices_path
    click_link_or_button 'Add application'
    choose 'Yes, I know where I want to apply'
    click_link_or_button t('continue')

    select 'Gorse SCITT (1N1)'
    click_link_or_button t('continue')

    choose 'Mathematics (VTDR)'
    click_link_or_button t('continue')

    click_link_or_button 'Review application'
    click_link_or_button 'Continue without editing'
    click_link_or_button 'Confirm and submit application'
  end

  def candidate_fills_in_apply_again_with_four_course_choices
    choose 'Yes, I know where I want to apply'
    click_link_or_button t('continue')
    select 'Gorse SCITT (1N1)'
    click_link_or_button t('continue')
    choose 'Primary (2XT2)'
    click_link_or_button t('continue')

    click_link_or_button 'Add another course'
    choose 'Yes, I know where I want to apply'
    click_link_or_button t('continue')
    select 'Gorse SCITT (1N1)'
    click_link_or_button t('continue')
    choose 'Drama (2397)'
    click_link_or_button t('continue')

    click_link_or_button 'Add another course'
    choose 'Yes, I know where I want to apply'
    click_link_or_button t('continue')
    select 'Gorse SCITT (1N1)'
    click_link_or_button t('continue')
    choose 'English (6Z9H)'
    click_link_or_button t('continue')

    click_link_or_button 'Add another course'
    choose 'Yes, I know where I want to apply'
    click_link_or_button t('continue')
    select 'Gorse SCITT (1N1)'
    click_link_or_button t('continue')
    choose 'Biology (2392)'
    click_link_or_button t('continue')
  end

  def candidate_fills_in_personal_details(international: false)
    scope = 'application_form.personal_details'
    fill_in t('first_name.label', scope:), with: 'Lando'
    fill_in t('last_name.label', scope:), with: 'Calrissian'

    fill_in 'Day', with: '6'
    fill_in 'Month', with: '4'
    fill_in 'Year', with: '1990'
    click_link_or_button t('save_and_continue')

    if international
      check 'Citizen of a different country'
      within('#candidate-interface-nationalities-form-other-nationality1-field') do
        select 'Indian'
      end
      click_link_or_button t('save_and_continue')
      choose 'Yes'
      click_link_or_button t('save_and_continue')
      choose 'Other'
      fill_in(
        'Enter visa type or immigration status',
        with: 'I have settled status',
      )
    else
      check 'British'
      check 'Citizen of a different country'
      within('#candidate-interface-nationalities-form-other-nationality1-field') do
        select 'American'
      end
    end
    click_link_or_button t('save_and_continue')
    choose t('application_form.completed_radio')
    click_link_or_button t('save_changes_and_return')
  end

  def candidate_fills_in_contact_details
    fill_in t('application_form.contact_details.phone_number.label'), with: '07700 900 982'
    click_link_or_button t('save_and_continue')

    choose 'In the UK'
    click_link_or_button t('save_and_continue')
    find(:css, "[autocomplete='address-line1']").fill_in with: '42 Much Wow Street'
    fill_in t('application_form.contact_details.address_line3.label.uk'), with: 'London'
    fill_in t('application_form.contact_details.postcode.label.uk'), with: 'SW1P 3BT'
    click_link_or_button t('save_and_continue')

    choose t('application_form.completed_radio')
    click_link_or_button t('save_changes_and_return')
  end

  def candidate_fills_in_international_contact_details
    fill_in t('application_form.contact_details.phone_number.label'), with: '07700 900 982'
    click_link_or_button t('save_and_continue')

    choose 'Outside the UK'
    select('India', from: t('application_form.contact_details.country.label'))
    click_link_or_button t('save_and_continue')
    fill_in 'candidate_interface_contact_details_form[address_line1]', with: 'Vishnu Gardens'
    fill_in 'candidate_interface_contact_details_form[address_line2]', with: 'New Delhi'
    fill_in 'candidate_interface_contact_details_form[address_line3]', with: 'Delhi'
    fill_in 'candidate_interface_contact_details_form[address_line4]', with: '110018'
    click_link_or_button t('save_and_continue')

    choose t('application_form.completed_radio')
    click_link_or_button t('save_changes_and_return')
  end

  def candidate_fills_in_efl_section
    click_link_or_button 'English as a foreign language'
    choose 'No, English is not a foreign language to me'
    click_link_or_button t('continue')
    choose 'Yes, I have completed this section'
    click_link_or_button t('save_changes_and_return')
  end

  def candidate_reviews_application
    visit candidate_interface_application_choices_path

    click_link_or_button 'Gorse SCITT'
    click_link_or_button 'Review application'
    click_link_or_button 'Continue without editing'
  end

  def candidate_fills_in_secondary_course_choice_with_incomplete_details
    visit candidate_interface_application_choices_path
    click_link_or_button 'Add application'
    choose 'Yes, I know where I want to apply'
    click_link_or_button t('continue')

    select 'Gorse SCITT (1N1)'
    click_link_or_button t('continue')

    choose 'Drama (2397)'
    click_link_or_button t('continue')
  end
  alias candidate_adds_a_draft_application candidate_fills_in_secondary_course_choice_with_incomplete_details

  def candidate_fills_in_secondary_course_choice
    visit candidate_interface_application_choices_path
    click_link_or_button 'Add application'
    choose 'Yes, I know where I want to apply'
    click_link_or_button t('continue')

    select 'Gorse SCITT (1N1)'
    click_link_or_button t('continue')

    choose 'Drama (2397)'
    click_link_or_button t('continue')

    click_link_or_button 'Review application'
    click_link_or_button 'Continue without editing'
    click_link_or_button 'Confirm and submit application'
  end

  def candidate_completes_details_except_science(with_referees: true, international: false, candidate: current_candidate)
    given_courses_exist
    create_and_sign_in_candidate(candidate:)

    ##########################################
    #
    # Filling out Your Details
    #
    ##########################################

    visit candidate_interface_details_path

    click_link_or_button t('page_titles.personal_information.heading')
    candidate_fills_in_personal_details(international:)

    click_link_or_button t('page_titles.contact_information')
    candidate_fills_in_contact_details

    click_link_or_button t('page_titles.work_history')

    candidate_fills_in_restructured_work_experience
    candidate_fills_in_restructured_work_experience_break

    if with_referees
      candidate_provides_two_referees
      receive_references
      advance_time_to(5.minutes.from_now)
      mark_references_as_complete
    end

    click_link_or_button t('page_titles.volunteering.short')

    candidate_fills_in_restructured_volunteering_role

    click_link_or_button t('page_titles.training_with_a_disability')
    candidate_fills_in_disability_info

    click_link_or_button t('page_titles.suitability_to_work_with_children')
    candidate_fills_in_safeguarding_issues

    click_link_or_button t('page_titles.degree')
    candidate_fills_in_their_degree

    click_link_or_button 'Maths GCSE or equivalent'
    candidate_fills_in_their_maths_gcse

    click_link_or_button 'English GCSE or equivalent'
    candidate_fills_in_their_english_gcse

    click_link_or_button(international ? 'Other qualifications' : 'A levels and other qualifications')
    candidate_fills_in_their_other_qualifications

    click_link_or_button t('application_form.personal_statement.label')
    candidate_fills_in_personal_statement

    click_link_or_button t('page_titles.interview_preferences.heading')
    candidate_fills_in_interview_preferences

    click_link_or_button 'Equality and diversity questions'
    if international
      candidate_fills_in_diversity_information(school_meals: false)
    else
      candidate_fills_in_diversity_information
    end

    if international
      click_link_or_button 'English as a foreign language'
      choose 'No, English is not a foreign language to me'
      click_link_or_button 'Continue'
      choose 'Yes, I have completed this section'
      click_link_or_button 'Continue'
    end
  end

  def candidate_fills_in_their_degree
    and_the_candidate_add_the_degree(
      degree_level: 'Bachelor degree',
      degree_type: 'Bachelor of Arts',
      degree_subject: 'Aerospace engineering',
      university: 'ThinkSpace Education',
      grade: 'First-class honours',
    )
  end

  def and_i_answer_that_i_have_a_university_degree
    choose 'Yes, I have a degree or am studying for one'
    click_link_or_button 'Continue'
  end

  def and_the_candidate_add_the_degree(degree_level:, degree_type:, degree_subject:, university:, grade:)
    visit candidate_interface_degree_review_path

    if current_candidate.current_application.application_qualifications.degree.empty?
      click_link_or_button 'Add a degree'
    else
      click_link_or_button 'Add another degree'
    end

    choose 'United Kingdom'
    click_link_or_button t('save_and_continue')

    choose degree_level
    click_link_or_button t('save_and_continue')

    select degree_subject, from: 'What subject is your degree?'
    click_link_or_button t('save_and_continue')

    choose degree_type
    click_link_or_button t('save_and_continue')

    select university, from: 'candidate_interface_degree_wizard[university]'
    click_link_or_button t('save_and_continue')

    choose 'Yes'
    click_link_or_button t('save_and_continue')

    if has_selector?('label', text: grade)
      choose grade
    else
      choose 'Yes'
      fill_in 'What grade did you get?', with: grade
    end
    click_link_or_button t('save_and_continue')

    fill_in t('page_titles.what_year_did_you_start_your_degree'), with: '2006'
    click_link_or_button t('save_and_continue')

    fill_in t('page_titles.what_year_did_you_graduate'), with: '2009'
    click_link_or_button t('save_and_continue')

    choose t('application_form.completed_radio')
    click_link_or_button t('save_changes_and_return')
  end

  def candidate_fills_in_their_other_qualifications
    choose 'A level'
    click_link_or_button t('continue')
    fill_in t('application_form.other_qualification.subject.label'), with: 'Believing in the Heart of the Cards'
    fill_in t('application_form.other_qualification.grade.label'), with: 'A'
    fill_in t('application_form.other_qualification.award_year.label'), with: '2015'
    choose 'No, not at the moment'
    click_link_or_button t('save_and_continue')
    choose t('application_form.completed_radio')
    click_link_or_button t('save_changes_and_return')
  end

  def candidate_fills_in_disability_info
    choose t('application_form.training_with_a_disability.disclose_disability.yes')
    fill_in t('application_form.training_with_a_disability.disability_disclosure.label'), with: 'I have difficulty climbing stairs'
    click_link_or_button t('continue')
    choose t('application_form.completed_radio')
    click_link_or_button t('save_changes_and_return')
  end

  def candidate_fills_in_safeguarding_issues
    choose 'Yes'
    fill_in 'Give any relevant information', with: 'I have a criminal conviction.'
    click_link_or_button t('continue')
    choose t('application_form.completed_radio')
    click_link_or_button t('save_changes_and_return')
  end

  def candidate_fills_in_restructured_work_experience
    choose 'Yes'
    click_link_or_button t('continue')

    click_link_or_button 'Add a job'

    with_options scope: 'application_form.restructured_work_history' do |locale|
      fill_in locale.t('employer.label'), with: 'Weyland-Yutani'
      fill_in locale.t('role.label'), with: 'Chief Terraforming Officer'

      choose 'Part time'

      within('[data-qa="start-date"]') do
        fill_in 'Month', with: '5'
        fill_in 'Year', with: '2014'
      end

      within('[data-qa="currently-working"]') do
        choose 'No'
      end

      within('[data-qa="end-date"]') do
        fill_in 'Month', with: '1'
        fill_in 'Year', with: '2019'
      end

      within('[data-qa="relevant-skills"]') do
        choose 'Yes'
      end

      click_link_or_button t('save_and_continue')
    end
  end

  def candidate_fills_in_restructured_work_experience_break
    click_link_or_button 'add a reason for this break', match: :first
    fill_in 'Enter reasons for break in work history', with: 'Terraforming is tiring.'
    click_link_or_button t('continue')

    choose t('application_form.completed_radio')
    click_link_or_button t('save_changes_and_return')
  end

  def candidate_fills_in_restructured_volunteering_role
    choose 'Yes' # "Do you have any relevant unpaid experience?"
    click_link_or_button t('save_and_continue')

    with_options scope: 'application_form.volunteering' do |locale|
      fill_in locale.t('organisation.label'), with: 'National Trust'
      fill_in locale.t('role.label'), with: 'Tour guide'

      within('[data-qa="working-with-children"]') do
        choose 'Yes'
      end

      within('[data-qa="start-date"]') do
        fill_in 'Month', with: '5'
        fill_in 'Year', with: '2014'
      end

      within('[data-qa="currently-working"]') do
        choose 'No'
      end

      within('[data-qa="end-date"]') do
        fill_in 'Month', with: '1'
        fill_in 'Year', with: '2019'
      end

      fill_in t('application_form.volunteering.details.label'), with: 'I volunteered.'
      click_link_or_button t('save_and_continue')
    end

    choose t('application_form.completed_radio')
    click_link_or_button t('save_changes_and_return')
  end

  def candidate_fills_in_referee(params = {})
    referee_name = params[:name] || 'Terri Tudor'
    fill_in t('application_form.references.name.label'), with: referee_name
    click_link_or_button t('save_and_continue')
    fill_in t('application_form.references.email_address.label', referee_name:), with: params[:email_address] || 'terri@example.com'
    click_link_or_button t('save_and_continue')
    fill_in t('application_form.references.relationship.label', referee_name:), with: params[:relationship] || 'Tutor'
    click_link_or_button t('save_and_continue')
  end

  def candidate_provides_two_referees
    visit candidate_interface_references_start_path
    click_link_or_button 'Add reference'
    choose 'Academic'
    click_link_or_button t('continue')

    candidate_fills_in_referee

    click_link_or_button 'Add another reference'
    choose 'Professional'
    click_link_or_button t('continue')

    candidate_fills_in_referee(
      name: 'Anne Other',
      email_address: 'anne.other@example.com',
      relationship: 'First boss',
    )

    visit candidate_interface_details_path
  end

  def candidate_fills_in_their_maths_gcse
    choose('GCSE')
    click_link_or_button t('save_and_continue')
    fill_in('Grade', with: 'B')
    click_link_or_button t('save_and_continue')
    fill_in 'Year', with: '1990'
    click_link_or_button t('save_and_continue')
    choose t('application_form.completed_radio')
    click_link_or_button t('save_changes_and_return')
  end

  def candidate_fills_in_their_english_gcse
    choose('GCSE')
    click_link_or_button t('save_and_continue')
    check 'English (Single award)'
    fill_in('Grade', match: :first, with: 'B')
    click_link_or_button t('save_and_continue')
    fill_in 'Year', with: '1990'
    click_link_or_button t('save_and_continue')
    choose t('application_form.completed_radio')
    click_link_or_button t('save_changes_and_return')
  end

  def candidate_explains_a_missing_gcse
    choose('I do not have a qualification in science yet')
    click_link_or_button t('save_and_continue')
    choose 'Yes'
    fill_in 'candidate-interface-gcse-not-completed-form-not-completed-explanation-field', with: 'In progress'
    click_link_or_button t('save_and_continue')
    choose t('application_form.completed_radio')
    click_link_or_button t('save_changes_and_return')
  end

  def candidate_fills_in_personal_statement
    fill_in t('application_form.personal_statement.label'), with: 'I believe I would be a first-rate teacher'
    click_link_or_button t('continue')
    # Confirmation page
    choose t('application_form.completed_radio')
    click_link_or_button t('save_changes_and_return')
  end

  def candidate_fills_in_interview_preferences
    choose 'Yes'
    fill_in t('application_form.interview_preferences.yes_label'), with: 'Not on a Wednesday'
    click_link_or_button t('save_and_continue')
    # Confirmation page
    choose t('application_form.completed_radio')
    click_link_or_button t('save_changes_and_return')
  end

  def click_sign_in_link(email)
    matches = email.body.match(/(http:\/\/localhost:3000\/reference\?token=[\w-]{20})/)
    @reference_feedback_url = matches.captures.first unless matches.nil?
    @token = Rack::Utils.parse_query(URI(matches.captures.first).query)['token']

    email.click_link_or_button(@reference_feedback_url)
  end

  def click_change_link(row_description, first: false)
    link_text = "Change #{row_description}"
    matches = page.all('.govuk-summary-list__actions').select { |row| row.has_link?(link_text) }

    raise "No link was found for 'Change #{row_description}'.\nContent of the page:\n\n #{page.text}" if matches.count.zero?

    if matches.count > 1 && first == false
      raise "More than one '#{link_text}' link found. Use 'within' to scope this action to a more specific node in the document."
    else
      matches.pop.click_link_or_button(link_text)
    end
  end

  def within_summary_card(card_title, &block)
    within(page.find('.app-summary-card', text: card_title)) do
      block.call
    end
  end

  def within_summary_row(row_description, &block)
    within(page.find('.govuk-summary-list__row', text: row_description)) do
      block.call
    end
  end

  def within_task_list_item(title, &block)
    within(page.find('.app-task-list__item', text: title)) do
      block.call
    end
  end

  def expect_validation_error(message)
    errors = all('.govuk-error-message')
    expect(errors.map(&:text).one? { |e| e.include? message }).to be true
  end

  def current_candidate
    @current_candidate ||= create(:candidate)
  end

  def then_i_am_on_the_application_choice_review_page
    expect(application_choice).to be_present
    expect(page).to have_current_path(
      candidate_interface_course_choices_course_review_path(application_choice_id: application_choice.id),
    )
  end

  def then_i_can_add_course_choices
    expect(page).to have_current_path(candidate_interface_details_path)
    click_link_or_button 'Your applications'
    expect(page).to have_current_path(candidate_interface_application_choices_path)
    expect(page).to have_content('You can add up to 4 applications at a time.')
    click_link_or_button 'Add application'
    expect(page).to have_current_path(candidate_interface_course_choices_do_you_know_the_course_path)
  end

  def application_choice
    current_candidate.current_application.application_choices.last
  end

  def then_i_am_on_your_details_page
    expect(page).to have_current_path(candidate_interface_details_path)
  end

  def then_i_am_on_the_post_offer_dashboard
    expect(page).to have_current_path(candidate_interface_application_offer_dashboard_path)
  end

  def and_i_have_one_application_in_draft
    @application_form = create(:application_form, :completed, :with_degree, candidate: @current_candidate)
    @application_choice = create(:application_choice, :unsubmitted, application_form: @application_form)
  end

  def when_i_submit_one_of_my_draft_applications
    when_i_click_to_view_my_application
    when_i_click_to_review_my_application
    when_i_click_to_submit_my_application
  end

  def when_i_continue_my_draft_application
    when_i_visit_my_applications
    when_i_click_to_view_my_application
  end

  def when_i_visit_my_applications
    visit candidate_interface_application_choices_path
  end

  def and_i_continue_with_my_application
    when_i_visit_my_applications
    when_i_click_to_view_my_application
  end
  alias when_i_continue_with_my_application and_i_continue_with_my_application

  def when_i_click_to_view_my_application
    click_link_or_button @application_choice.current_course.provider.name
  end
  alias and_i_click_to_view_my_application when_i_click_to_view_my_application

  def when_i_click_to_review_my_application
    click_link_or_button 'Review application'
  end

  def when_i_click_to_submit_my_application
    click_link_or_button 'Confirm and submit application'
  end

  def when_i_continue_without_editing
    click_link_or_button 'Continue without editing'
  end

  def then_i_am_on_the_review_and_submit_page
    expect(page).to have_current_path(
      candidate_interface_course_choices_course_review_and_submit_path(@application_choice.id),
    )
  end

  def then_i_see_that_the_course_is_unavailable
    expect(page).to have_content('You cannot submit this application because the course is no longer available.')
    expect(page).to have_content('Remove this application and search for other courses.')
  end

  def and_i_click_continue
    click_link_or_button t('continue')
  end

  def when_i_click_to_withdraw_my_application
    click_link_or_button 'withdraw this application'
  end
end
