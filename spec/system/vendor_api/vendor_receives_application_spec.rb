require 'rails_helper'

# This is an end-to-end test for the API response. To test complex logic in
# the presenter, see spec/presenters/vendor_api/single_application_presenter_spec.rb.
RSpec.feature 'Vendor receives the application' do
  include CandidateHelper

  scenario 'A completed application is submitted with references' do
    given_a_candidate_has_submitted_their_application
    when_i_retrieve_the_application_over_the_api
    then_it_should_include_the_data_from_the_application_form
  end

  def given_a_candidate_has_submitted_their_application
    candidate_completes_application_form
    candidate_submits_application
  end

  def when_i_retrieve_the_application_over_the_api
    api_token = VendorAPIToken.create_with_random_token!(provider: @provider)
    page.driver.header 'Authorization', "Bearer #{api_token}"

    visit '/api/v1/applications?since=2019-01-01'

    @api_response = JSON.parse(page.body)
  end

  def then_it_should_include_the_data_from_the_application_form
    expected_attributes = {
      id: @provider.application_choices.first.id.to_s,
      type: 'application',
      attributes: {
        application_url: "http://localhost:3000/provider/applications/#{@provider.application_choices.first.id}",
        support_reference: @provider.application_forms.first.support_reference,
        personal_statement: "Why do you want to become a teacher?: I believe I would be a first-rate teacher \n What is your subject knowledge?: Everything",
        interview_preferences: 'Not on a Wednesday',
        hesa_itt_data: nil,
        offer: nil,
        contact_details: {
          phone_number: '07700 900 982',
          address_line1: '42 Much Wow Street',
          address_line2: '',
          address_line3: 'London',
          address_line4: '',
          postcode: 'SW1P 3BT',
          country: 'GB',
          email: @current_candidate.email_address,
        },
        course: {
          recruitment_cycle_year: RecruitmentCycle.current_year,
          provider_code: '1N1',
          site_code: '-',
          course_code: '2XT2',
          study_mode: 'full_time',
          start_date: '2020-09',
        },
        candidate: {
          id: "C#{@current_candidate.id}",
          first_name: 'Lando',
          last_name: 'Calrissian',
          date_of_birth: '1937-04-06',
          nationality: %w[GB US],
          domicile: @application.domicile,
          uk_residency_status: 'UK Citizen',
          uk_residency_status_code: 'A',
          fee_payer: '02',
          english_main_language: true,
          other_languages: nil,
          english_language_qualifications: nil,
          disability_disclosure: 'I have difficulty climbing stairs',
        },
        qualifications: {
          gcses: [
            {
              id: @application.english_gcse.constituent_grades['english_single_award']['public_id'],
              qualification_type: 'gcse',
              non_uk_qualification_type: nil,
              subject: 'English single award',
              subject_code: '100320',
              grade: 'B',
              start_year: nil,
              award_year: '1990',
              institution_details: nil,
              awarding_body: nil,
              equivalency_details: nil,
              hesa_degclss: nil,
              hesa_degctry: nil,
              hesa_degenddt: nil,
              hesa_degest: nil,
              hesa_degsbj: nil,
              hesa_degstdt: nil,
              hesa_degtype: nil,
            },
            {
              id: @application.maths_gcse.public_id,
              qualification_type: 'gcse',
              non_uk_qualification_type: nil,
              subject: 'maths',
              subject_code: '100403',
              grade: 'B',
              start_year: nil,
              award_year: '1990',
              institution_details: nil,
              awarding_body: nil,
              equivalency_details: nil,
              hesa_degclss: nil,
              hesa_degctry: nil,
              hesa_degenddt: nil,
              hesa_degest: nil,
              hesa_degsbj: nil,
              hesa_degstdt: nil,
              hesa_degtype: nil,
            },
          ],
          degrees: [
            {
              id: @application.qualification_in_subject(:degree, 'Doge').public_id,
              qualification_type: 'BA',
              non_uk_qualification_type: nil,
              subject: 'Doge',
              subject_code: nil,
              grade: 'First class honours',
              start_year: '2006',
              award_year: '2009',
              institution_details: 'University of Much Wow',
              awarding_body: nil,
              equivalency_details: nil,
              hesa_degclss: '01',
              hesa_degctry: nil,
              hesa_degenddt: '2009-01-01',
              hesa_degest: nil,
              hesa_degsbj: nil,
              hesa_degstdt: '2006-01-01',
              hesa_degtype: nil,
            },
          ],
          other_qualifications: [
            {
              id: @application.qualification_in_subject(:other, 'Believing in the Heart of the Cards').public_id,
              qualification_type: 'A level',
              non_uk_qualification_type: nil,
              subject: 'Believing in the Heart of the Cards',
              subject_code: nil,
              grade: 'A',
              start_year: nil,
              award_year: '2015',
              institution_details: nil,
              awarding_body: nil,
              equivalency_details: nil,
              hesa_degclss: nil,
              hesa_degctry: nil,
              hesa_degenddt: nil,
              hesa_degest: nil,
              hesa_degsbj: nil,
              hesa_degstdt: nil,
              hesa_degtype: nil,
            },
          ],
          missing_gcses_explanation: 'Science GCSE or equivalent: In progress',
        },
        recruited_at: nil,
        references: [
          {
            id: @application.application_references.first.id,
            name: 'Terri Tudor',
            email: 'terri@example.com',
            referee_type: 'academic',
            relationship: 'Tutor',
            reference: 'My ideal person',
            safeguarding_concerns: false,
          },
          {
            id: @application.application_references.last.id,
            name: 'Anne Other',
            email: 'anne@other.com',
            referee_type: 'professional',
            relationship: 'First boss',
            reference: 'Lovable',
            safeguarding_concerns: false,
          },
        ],
        rejection: nil,
        status: 'awaiting_provider_decision',
        phase: 'apply_1',
        submitted_at: @application.submitted_at.iso8601,
        updated_at: @application.application_choices.first.updated_at.iso8601,
        reject_by_default_at: @application.application_choices.first.reject_by_default_at.iso8601,
        withdrawal: nil,
        further_information: '',
        safeguarding_issues_status: 'has_safeguarding_issues_to_declare',
        safeguarding_issues_details_url: Rails.application.routes.url_helpers.provider_interface_application_choice_url(@provider.application_choices.first.id, anchor: 'criminal-convictions-and-professional-misconduct'),
        work_experience: {
          jobs: [
            {
              id: @application.application_work_experiences.first.id,
              start_date: '2014-05-01',
              end_date: '2019-01-01',
              role: 'Chief Terraforming Officer',
              organisation_name: 'Weyland-Yutani',
              working_with_children: nil,
              commitment: 'part_time',
              description: 'I used skills relevant to teaching in this job.',
            },
          ],
          volunteering: [
            {
              id: @application.application_volunteering_experiences.first.id,
              start_date: '2014-05-01',
              end_date: '2019-01-01',
              role: 'Tour guide',
              organisation_name: 'National Trust',
              working_with_children: true,
              commitment: nil,
              description: 'I volunteered.',
            },
          ],
          work_history_break_explanation: 'January 2019 to October 2019: Terraforming is tiring.',
        },
      },
    }

    received_attributes = @api_response['data'].first.deep_symbolize_keys
    expect(received_attributes.deep_sort).to eq expected_attributes.deep_sort
  end
end
