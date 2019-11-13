require 'rails_helper'

RSpec.feature 'Vendor receives the application' do
  include CandidateHelper

  scenario 'A completed application is submitted with references' do
    Timecop.freeze do # simplify date assertions in the response
      given_a_candidate_has_submitted_their_application
      and_references_have_been_received
      and_the_edit_by_date_has_passed
      and_the_daily_application_cron_job_has_run

      when_i_retrieve_the_application_over_the_api
      then_it_should_include_the_data_from_the_application_form
    end
  end

  def given_a_candidate_has_submitted_their_application
    candidate_completes_application_form
    candidate_submits_application
  end

  def and_references_have_been_received
    create(:reference,
           application_form: @application,
           email_address: 'FIRST_REF@example.com')

    create(:reference,
           application_form: @application,
           email_address: 'SECOND_REF@example.com')

    ReceiveReference.new(application_form: @application,
                         referee_email: 'FIRST_REF@example.com',
                         feedback: 'My ideal person').save

    ReceiveReference.new(application_form: @application,
                         referee_email: 'SECOND_REF@example.com',
                         feedback: 'Lovable').save
  end

  def and_the_edit_by_date_has_passed
    @application.application_choices.first.update(edit_by: 1.minute.ago)
  end

  def and_the_daily_application_cron_job_has_run
    # TODO: Replace with a call to the outermost cron job, once it exists
    SendApplicationsToProvider.new.call
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
