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
    subject_knowledge
    interview_preferences
    references_selected
  ].freeze

  def create_and_sign_in_candidate(candidate: current_candidate)
    login_as(candidate)
  end

  def application_form_sections
    APPLICATION_FORM_SECTIONS
  end

  def candidate_completes_application_form(with_referees: true, international: false, candidate: current_candidate)
    given_courses_exist
    create_and_sign_in_candidate(candidate: candidate)
    visit candidate_interface_application_form_path

    click_link 'Choose your courses'

    candidate_fills_in_apply_again_course_choice

    click_link t('page_titles.personal_information.heading')
    candidate_fills_in_personal_details(international: international)

    click_link t('page_titles.contact_information')
    candidate_fills_in_contact_details

    click_link t('page_titles.work_history')

    candidate_fills_in_restructured_work_experience
    candidate_fills_in_restructured_work_experience_break

    if with_referees
      candidate_provides_two_referees
      receive_references
      Timecop.travel(5.minutes.from_now) do
        select_references_and_complete_section
      end
    end

    click_link t('page_titles.volunteering.short')

    candidate_fills_in_restructured_volunteering_role

    click_link t('page_titles.training_with_a_disability')
    candidate_fills_in_disability_info

    click_link t('page_titles.suitability_to_work_with_children')
    candidate_fills_in_safeguarding_issues

    click_link t('page_titles.degree')
    candidate_fills_in_their_degree

    click_link 'Maths GCSE or equivalent'
    candidate_fills_in_their_maths_gcse

    click_link 'English GCSE or equivalent'
    candidate_fills_in_their_english_gcse

    click_link 'Science GCSE or equivalent'
    candidate_explains_a_missing_gcse

    click_link(international ? 'Other qualifications' : 'A levels and other qualifications')
    candidate_fills_in_their_other_qualifications

    click_link 'Why you want to teach'
    candidate_fills_in_becoming_a_teacher

    click_link 'Your suitability to teach a subject or age group'
    candidate_fills_in_subject_knowledge

    click_link t('page_titles.interview_preferences')
    candidate_fills_in_interview_preferences

    if international
      click_link t('page_titles.efl.review')
      choose 'No, English is not a foreign language to me'
      click_button 'Continue'
      choose 'Yes, I have completed this section'
      click_button 'Continue'
    end

    @application = ApplicationForm.last
  end

  def candidate_submits_application
    click_link 'Check and submit your application'
    click_link t('continue')

    # Equality and diversity questions
    click_link t('continue')

    # What is your sex?
    choose 'Prefer not to say'
    click_button t('continue')

    # Are you disabled?
    choose 'Prefer not to say'
    click_button t('continue')

    # What is your ethnic group?
    choose 'Prefer not to say'
    click_button t('continue')

    # Review page
    click_link t('continue')

    # Is there anything else you would like to tell us about your application?
    choose 'No'
    click_button 'Send application'

    @application = ApplicationForm.last
  end

  def receive_references
    application_form = ApplicationForm.last
    first_reference = application_form.application_references.first

    first_reference.update!(
      feedback: 'My ideal person',
      relationship_correction: '',
      safeguarding_concerns: '',
    )

    SubmitReference.new(
      reference: first_reference,
    ).save!

    second_reference = application_form.application_references.second

    second_reference.update!(
      feedback: 'Lovable',
      relationship_correction: '',
      safeguarding_concerns: '',
    )

    SubmitReference.new(
      reference: second_reference,
    ).save!
  end

  def select_references_and_complete_section
    visit candidate_interface_application_form_path
    click_link 'Select 2 references'
    application_form = ApplicationForm.last
    first_reference = application_form.application_references.feedback_provided.first
    second_reference = application_form.application_references.feedback_provided.second
    check first_reference.name
    check second_reference.name
    click_button t('save_and_continue')

    choose 'Yes, I have completed this section'
    click_button t('save_and_continue')
  end

  def given_courses_exist
    @provider = create(:provider, name: 'Gorse SCITT', code: '1N1', provider_type: 'scitt')
    site = create(:site, name: 'Main site', code: '-', provider: @provider, uuid: '9ad872fe-9461-4db6-a82a-f24b9a651bf2')
    course =
      Course.find_by(code: '2XT2', provider: @provider) ||
      create(:course, exposed_in_find: true, open_on_apply: true, name: 'Primary', code: '2XT2', provider: @provider, start_date: Date.new(2020, 9, 1), level: :primary)
    course2 =
      Course.find_by(code: '2397', provider: @provider) ||
      create(:course, exposed_in_find: true, open_on_apply: true, name: 'Drama', code: '2397', provider: @provider, start_date: Date.new(2020, 9, 1), level: :primary)
    course3 =
      Course.find_by(code: '6Z9H', provider: @provider) ||
      create(:course, exposed_in_find: true, open_on_apply: true, name: 'English', code: '6Z9H', provider: @provider, start_date: Date.new(2020, 9, 1), level: :primary)
    create(:course_option, site: site, course: course) unless CourseOption.find_by(site: site, course: course, study_mode: :full_time)
    create(:course_option, site: site, course: course2) unless CourseOption.find_by(site: site, course: course2, study_mode: :full_time)
    create(:course_option, site: site, course: course3) unless CourseOption.find_by(site: site, course: course3, study_mode: :full_time)
  end

  def candidate_fills_in_apply_again_course_choice
    choose 'Yes, I know where I want to apply'
    click_button t('continue')

    select 'Gorse SCITT (1N1)'
    click_button t('continue')

    choose 'Primary (2XT2)'
    click_button t('continue')

    choose t('application_form.completed_radio')
    click_button t('continue')
  end

  def candidate_fills_in_apply_again_with_three_course_choices
    choose 'Yes, I know where I want to apply'
    click_button t('continue')

    select 'Gorse SCITT (1N1)'
    click_button t('continue')

    choose 'Primary (2XT2)'
    click_button t('continue')
    click_link 'Add another course'
    choose 'Yes, I know where I want to apply'
    click_button t('continue')
    select 'Gorse SCITT (1N1)'
    click_button t('continue')
    choose 'Drama (2397)'
    click_button t('continue')

    click_link 'Add another course'
    choose 'Yes, I know where I want to apply'
    click_button t('continue')
    select 'Gorse SCITT (1N1)'
    click_button t('continue')
    choose 'English (6Z9H)'
    click_button t('continue')
  end

  def candidate_fills_in_personal_details(international: false)
    scope = 'application_form.personal_details'
    fill_in t('first_name.label', scope: scope), with: 'Lando'
    fill_in t('last_name.label', scope: scope), with: 'Calrissian'

    fill_in 'Day', with: '6'
    fill_in 'Month', with: '4'
    fill_in 'Year', with: '1937'
    click_button t('save_and_continue')

    if international
      check 'Citizen of a different country'
      within('#candidate-interface-nationalities-form-other-nationality1-field') do
        select 'Indian'
      end
      click_button t('save_and_continue')
      choose 'Yes'
      click_button t('save_and_continue')
      fill_in(
        'What is your immigration status?',
        with: 'I have settled status',
      )
    else
      check 'British'
      check 'Citizen of a different country'
      within('#candidate-interface-nationalities-form-other-nationality1-field') do
        select 'American'
      end
    end
    click_button t('save_and_continue')
    choose t('application_form.completed_radio')
    click_button t('continue')
  end

  def candidate_fills_in_contact_details
    fill_in t('application_form.contact_details.phone_number.label'), with: '07700 900 982'
    click_button t('save_and_continue')

    choose 'In the UK'
    click_button t('save_and_continue')
    find(:css, "[autocomplete='address-line1']").fill_in with: '42 Much Wow Street'
    fill_in t('application_form.contact_details.address_line3.label.uk'), with: 'London'
    fill_in t('application_form.contact_details.postcode.label.uk'), with: 'SW1P 3BT'
    click_button t('save_and_continue')

    choose t('application_form.completed_radio')
    click_button t('continue')
  end

  def candidate_fills_in_international_contact_details
    fill_in t('application_form.contact_details.phone_number.label'), with: '07700 900 982'
    click_button t('save_and_continue')

    choose 'Outside the UK'
    select('India', from: t('application_form.contact_details.country.label'))
    click_button t('save_and_continue')
    fill_in 'candidate_interface_contact_details_form[address_line1]', with: 'Vishnu Gardens'
    fill_in 'candidate_interface_contact_details_form[address_line2]', with: 'New Delhi'
    fill_in 'candidate_interface_contact_details_form[address_line3]', with: 'Delhi'
    fill_in 'candidate_interface_contact_details_form[address_line4]', with: '110018'
    click_button t('save_and_continue')

    choose t('application_form.completed_radio')
    click_button t('continue')
  end

  def candidate_fills_in_their_degree
    and_the_candidate_add_the_degree(
      degree_type: 'Bachelor of Arts',
      degree_subject: 'Aerospace engineering',
      institution: 'ThinkSpace Education',
      grade: 'First-class honours',
    )
  end

  def and_the_candidate_add_the_degree(degree_type:, degree_subject:, institution:, grade:)
    visit candidate_interface_new_degree_path

    choose 'UK degree'
    select degree_type, from: 'Type of degree'
    click_button t('save_and_continue')

    select degree_subject, from: 'What subject is your degree?'
    click_button t('save_and_continue')

    select institution, from: 'Which institution did you study at?'
    click_button t('save_and_continue')

    expect(page).to have_content('Have you completed your degree?')
    choose 'Yes'
    click_button t('save_and_continue')

    choose grade
    click_button t('save_and_continue')

    year_with_trailing_space = '2006 '
    fill_in t('page_titles.what_year_did_you_start_your_degree'), with: year_with_trailing_space
    click_button t('save_and_continue')
    year_with_preceding_space = ' 2009'
    fill_in t('page_titles.what_year_did_you_graduate'), with: year_with_preceding_space
    click_button t('save_and_continue')
    choose t('application_form.completed_radio')
    click_button t('continue')
  end

  def candidate_fills_in_their_other_qualifications
    choose 'A level'
    click_button t('continue')
    fill_in t('application_form.other_qualification.subject.label'), with: 'Believing in the Heart of the Cards'
    fill_in t('application_form.other_qualification.grade.label'), with: 'A'
    fill_in t('application_form.other_qualification.award_year.label'), with: '2015'
    choose 'No, not at the moment'
    click_button t('save_and_continue')
    choose t('application_form.completed_radio')
    click_button t('continue')
  end

  def candidate_fills_in_disability_info
    choose t('application_form.training_with_a_disability.disclose_disability.yes')
    fill_in t('application_form.training_with_a_disability.disability_disclosure.label'), with: 'I have difficulty climbing stairs'
    click_button t('continue')
    choose t('application_form.completed_radio')
    click_button t('continue')
  end

  def candidate_fills_in_safeguarding_issues
    choose 'Yes'
    fill_in 'Give any relevant information', with: 'I have a criminal conviction.'
    click_button t('continue')
    choose t('application_form.completed_radio')
    click_button t('continue')
  end

  def candidate_fills_in_restructured_work_experience
    choose 'Yes'
    click_button t('continue')

    click_link 'Add a job'

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

      click_button t('save_and_continue')
    end
  end

  def candidate_fills_in_restructured_work_experience_break
    click_link 'add a reason for this break', match: :first
    fill_in 'Enter reasons for break in work history', with: 'Terraforming is tiring.'
    click_button t('continue')

    choose t('application_form.completed_radio')
    click_button t('continue')
  end

  def candidate_fills_in_restructured_volunteering_role
    choose 'Yes' # "Do you have any relevant unpaid experience?"
    click_button t('save_and_continue')

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
      click_button t('save_and_continue')
    end

    choose t('application_form.completed_radio')
    click_button t('continue')
  end

  def candidate_fills_in_referee(params = {})
    fill_in t('application_form.references.name.label'), with: params[:name] || 'Terri Tudor'
    click_button t('save_and_continue')
    fill_in t('application_form.references.email_address.label'), with: params[:email_address] || 'terri@example.com'
    click_button t('save_and_continue')
    fill_in t('application_form.references.relationship.label'), with: params[:relationship] || 'Tutor'
    click_button t('save_and_continue')
  end

  def candidate_provides_two_referees
    visit candidate_interface_references_start_path
    click_link t('continue')
    choose 'Academic'
    click_button t('continue')

    candidate_fills_in_referee
    choose 'Yes, send a reference request now'
    click_button t('save_and_continue')

    click_link 'Request a second reference'
    click_link t('continue')
    choose 'Professional'
    click_button t('continue')

    candidate_fills_in_referee(
      name: 'Anne Other',
      email_address: 'anne@other.com',
      relationship: 'First boss',
    )
    choose 'Yes, send a reference request now'
    click_button t('save_and_continue')
    visit candidate_interface_application_form_path
  end

  def candidate_fills_in_their_maths_gcse
    choose('GCSE')
    click_button t('save_and_continue')
    fill_in('Grade', with: 'B')
    click_button t('save_and_continue')
    fill_in 'Year', with: '1990'
    click_button t('save_and_continue')
    choose t('application_form.completed_radio')
    click_button t('continue')
  end

  def candidate_fills_in_their_english_gcse
    choose('GCSE')
    click_button t('save_and_continue')
    check 'English (Single award)'
    fill_in('Grade', match: :first, with: 'B')
    click_button t('save_and_continue')
    fill_in 'Year', with: '1990'
    click_button t('save_and_continue')
    choose t('application_form.completed_radio')
    click_button t('continue')
  end

  def candidate_explains_a_missing_gcse
    choose('I do not have a GCSE in science (or equivalent) yet')
    click_button t('save_and_continue')
    choose 'Yes'
    fill_in 'candidate-interface-gcse-not-completed-form-not-completed-explanation-field', with: 'In progress'
    click_button t('save_and_continue')
    choose t('application_form.completed_radio')
    click_button t('continue')
  end

  def candidate_fills_in_becoming_a_teacher
    fill_in t('application_form.personal_statement.becoming_a_teacher.label'), with: 'I believe I would be a first-rate teacher'
    click_button t('continue')
    # Confirmation page
    choose t('application_form.completed_radio')
    click_button t('continue')
  end

  def candidate_fills_in_subject_knowledge
    fill_in t('application_form.personal_statement.subject_knowledge.label'), with: 'Everything'
    click_button t('continue')
    # Confirmation page
    choose t('application_form.completed_radio')
    click_button t('continue')
  end

  def candidate_fills_in_interview_preferences
    choose 'Yes'
    fill_in t('application_form.personal_statement.interview_preferences.yes_label'), with: 'Not on a Wednesday'
    click_button t('save_and_continue')
    # Confirmation page
    choose t('application_form.completed_radio')
    click_button t('continue')
  end

  def click_sign_in_link(email)
    matches = email.body.match(/(http:\/\/localhost:3000\/reference\?token=[\w-]{20})/)
    @reference_feedback_url = matches.captures.first unless matches.nil?
    @token = Rack::Utils.parse_query(URI(matches.captures.first).query)['token']

    email.click_link(@reference_feedback_url)
  end

  def click_change_link(row_description)
    link_text = "Change #{row_description}"
    matches = page.all('.govuk-summary-list__actions').select { |row| row.has_link?(link_text) }

    if matches.count > 1
      raise "More than one '#{link_text}' link found. Use 'within' to scope this action to a more specific node in the document."
    else
      matches.pop.click_link(link_text)
    end
  end

  def within_summary_card(card_title, &block)
    within(page.all('.app-summary-card').find { |row| row.has_text?(card_title) }) do
      block.call
    end
  end

  def within_summary_row(row_description, &block)
    within(page.all('.govuk-summary-list__row').find { |row| row.has_text?(row_description) }) do
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
end
