require 'rails_helper'

RSpec.feature 'Vendor receives the application' do
  include CandidateHelper

  scenario 'A completed application is submitted with references' do
    Timecop.freeze do # simplify date assertions in the response
      given_a_candidate_has_submitted_their_application
      and_references_have_been_received
      when_i_retrieve_the_application_over_the_api
      then_it_should_include_the_data_from_the_application_form
    end
  end

  def given_a_candidate_has_submitted_their_application
    @provider = create(:provider, name: 'Gorse SCITT', code: '1N1')
    site = create(:site, name: 'Main site', code: '-', provider: @provider)
    course = create(:course, name: 'Primary', code: '2XT2', provider: @provider)
    create(:course_option, site: site, course: course, vacancy_status: 'B')

    create_and_sign_in_candidate
    visit candidate_interface_application_form_path

    click_link 'Course choices'
    click_link 'Add course'
    choose 'Yes, I know where I want to apply'
    click_button 'Continue'

    select 'Gorse SCITT (1N1)'
    click_button 'Continue'

    select 'Primary (2XT2)'
    click_button 'Continue'

    choose 'Main site'
    click_button 'Continue'

    click_link 'Back to application'

    click_link t('page_titles.personal_details')
    candidate_fills_in_personal_details(scope: 'application_form.personal_details')
    click_button t('complete_form_button', scope: 'application_form.personal_details')
    click_link t('complete_form_button', scope: 'application_form.personal_details')

    click_link t('page_titles.contact_details')
    visit candidate_interface_contact_details_edit_base_path
    candidate_fills_in_contact_details
    click_button t('application_form.contact_details.address.button')
    click_link t('application_form.contact_details.review.button')

    click_link t('page_titles.work_history')
    choose t('application_form.work_history.more_than_5')
    click_button 'Continue'
    candidate_fills_in_work_experience
    click_button t('application_form.work_history.complete_form_button')
    check t('application_form.work_history.review.completed_checkbox')
    click_button t('application_form.work_history.review.button')

    click_link t('page_titles.training_with_a_disability')
    candidate_fills_in_disability_info
    click_button t('application_form.training_with_a_disability.complete_form_button')
    click_link t('application_form.training_with_a_disability.review.button')

    click_link t('page_titles.degree')
    visit candidate_interface_degrees_new_base_path
    candidate_fills_in_their_degree
    click_button t('application_form.degree.base.button')
    check t('application_form.degree.review.completed_checkbox')
    click_button t('application_form.degree.review.button')

    click_link 'Maths GCSE or equivalent'
    candidate_fills_in_a_gcse
    click_button 'Save and continue'
    click_link 'Back to application'

    click_link 'English GCSE or equivalent'
    candidate_fills_in_a_gcse
    click_button 'Save and continue'
    click_link 'Back to application'

    click_link 'Other relevant academic and non-academic qualifications'
    candidate_fills_in_their_other_qualifications
    click_button t('application_form.other_qualification.base.button')
    check t('application_form.other_qualification.review.completed_checkbox')
    click_button t('application_form.other_qualification.review.button')

    click_link 'Why do you want to be a teacher?'
    fill_in t('application_form.personal_statement.becoming_a_teacher.label'), with: 'I WANT I WANT I WANT I WANT'
    click_button t('application_form.personal_statement.becoming_a_teacher.complete_form_button')
    # Confirmation page
    click_link t('application_form.personal_statement.becoming_a_teacher.complete_form_button')

    click_link 'What do you know about the subject you want to teach?'
    fill_in t('application_form.personal_statement.subject_knowledge.label'), with: 'Everything'
    click_button t('application_form.personal_statement.subject_knowledge.complete_form_button')
    # Confirmation page
    click_link t('application_form.personal_statement.subject_knowledge.complete_form_button')

    click_link 'Interview preferences'
    fill_in t('application_form.personal_statement.interview_preferences.label'), with: 'NOT WEDNESDAY'
    click_button t('application_form.personal_statement.interview_preferences.complete_form_button')
    # Confirmation page
    click_link t('application_form.personal_statement.interview_preferences.complete_form_button')

    # TODO: Referees

    click_link 'Check your answers before submitting'
    click_link 'Continue'
    choose 'No' # "Is there anything else you would like to tell us?"

    click_button 'Submit application'

    @application = ApplicationForm.last
  end

  def and_references_have_been_received
    # TODO Replace with the service object from https://github.com/DFE-Digital/apply-for-postgraduate-teacher-training/pull/471
    create(:reference,
           application_form: @application,
           email_address: 'FIRST_REF@example.com')

    create(:reference,
           application_form: @application,
           email_address: 'SECOND_REF@example.com')

    ReceiveReference.new(application_form: @application,
                         referee_email: 'FIRST_REF@example.com',
                         reference: 'My ideal person').save

    @application.reload # workaround for bug fixed in above PR

    ReceiveReference.new(application_form: @application,
                         referee_email: 'SECOND_REF@example.com',
                         reference: 'Lovable').save

    ApplicationStateChange.new(@application.application_choices.first).send_to_provider!
  end

  def when_i_retrieve_the_application_over_the_api
    api_token = VendorApiToken.create_with_random_token!(provider: @provider)
    page.driver.header 'Authorization', "Bearer #{api_token}"

    visit '/api/v1/applications?since=2019-01-01'

    @api_response = JSON.parse(page.body)
  end

  def then_it_should_include_the_data_from_the_application_form
    expected_attributes = {
      id: @provider.application_choices.first.id.to_s,
      type: 'application',
      attributes: {
        personal_statement: nil,
        hesa_itt_data: {
          disability: '',
          ethnicity: '',
          sex: '',
        },
        offer: nil,
        contact_details: {
          phone_number: '07700 900 982',
          address_line1: '42 Much Wow Street',
          address_line2: '',
          address_line3: 'London',
          address_line4: '',
          postcode: 'SW1P 3BT',
          country: nil,
          email: @current_candidate.email_address,
        },
        course: {
          start_date: '2020-09-01', # TODO: Necessary?
          provider_ucas_code: '1N1',
          site_ucas_code: '-',
          course_ucas_code: '2XT2',
        },
        candidate: {
          first_name: 'Lando',
          last_name: 'Calrissian',
          date_of_birth: '1937-04-06',
          nationality: %w[US], # TODO: BROKEN, should be [UK, US]
          uk_residency_status: nil,
          english_main_language: true,
          english_language_qualifications:  "I'm great at Galactic Basic so English is a piece of cake",
          other_languages: '',
          disability_disclosure: 'I have difficulty climbing stairs',
        },
        qualifications: { # TODO: This section is hardcoded in the presenter
          gcses: [
            {
              qualification_type: 'GCSE',
              subject: 'Maths',
              grade: 'A',
              award_year: '2001',
              equivalency_details: nil,
              institution_details: nil,
            },
            {
              qualification_type: 'GCSE',
              subject: 'English',
              grade: 'A',
              award_year: '2001',
              equivalency_details: nil,
              institution_details: nil,
            },
          ],
          degrees: [
            {
              qualification_type: 'BA',
              subject: 'Geography',
              grade: '2.1',
              award_year: '2007',
              equivalency_details: nil,
              institution_details: 'Imperial College London',
            },
          ],
          other_qualifications: [
            {
              qualification_type: 'A Level',
              subject: 'Chemistry',
              grade: 'B',
              award_year: '2004',
              equivalency_details: nil,
              institution_details: 'Harris Westminster Sixth Form',
            },
          ],
        },
        references: [ # TODO: This section is hardcoded in the presenter
          {
            name: 'John Smith',
            email: 'johnsmith@example.com',
            phone_number: '07999 111111',
            relationship: 'BA Geography course director at Imperial College. I tutored the candidate for one academic year.',
            confirms_safe_to_work_with_children: true,
            reference: <<~HEREDOC,
                Fantastic personality. Great with people. Strong communicator .  Excellent character. Passionate about teaching . Great potential.  A charismatic talented able young person who is far better than her official degree result. An exceptional person.

                Passion for their subject	7 / 10
                Knowledge about their subject	10 / 10
                General academic performance	9 / 10
                Ability to meet deadlines and organise their time	7 / 10
                Ability to think critically	10 / 10
                Ability to work collaboratively	Don’t know
                Mental and emotional resilience	8 / 10
                Literacy	9 / 10
                Numeracy	7 / 10
            HEREDOC
          },
          {
            name: 'Jane Brown',
            email: 'janebrown@example.com',
            phone_number: '07111 999999',
            relationship: 'Headmistress at Harris Westminster Sixth Form',
            confirms_safe_to_work_with_children: true,
            reference: <<~HEREDOC,
                An ideal teacher. Brisk and lively communicator. Intelligent and self-aware. Good with children. Led education outreach workshops.

                Passion for their subject	7 / 10
                Knowledge about their subject	10 / 10
                General academic performance	9 / 10
                Ability to meet deadlines and organise their time	7 / 10
                Ability to think critically	10 / 10
                Ability to work collaboratively	Don’t know
                Mental and emotional resilience	8 / 10
                Literacy	9 / 10
                Numeracy	7 / 10
            HEREDOC
          },
        ],
        rejection: nil,
        status: 'awaiting_provider_decision',
        submitted_at: @application.submitted_at.iso8601,
        updated_at: @application.application_choices.first.updated_at.iso8601,
        withdrawal: nil,
        further_information: '',
        work_experience: {
          jobs: [
            {
              start_date: '2014-05-01',
              end_date: '2019-01-01',
              role: 'Teacher',
              organisation_name: 'Oakleaf Primary School',
              working_with_children: false,
              commitment: 'full_time',
              description: 'I learned a lot about teaching',
            },
          ],
          volunteering: [],
        },
      },
    }

    expect(@api_response['data'].first.deep_symbolize_keys).to eq expected_attributes
  end
end
