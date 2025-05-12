require 'rails_helper'

# This is an end-to-end test for the API response. To test complex logic in
# the presenter, see spec/presenters/register_api/single_application_presenter_spec.rb.
RSpec.describe 'Register receives an application data', time: CycleTimetableHelper.mid_cycle(2025) do
  include CandidateHelper

  before do
    @current_year = current_year
  end

  scenario 'A candidate is recruited in a postgraduate course' do
    given_a_provider_recruited_a_candidate_that_applied_to_a_postgraduate_course
    when_i_retrieve_the_application_over_the_api
    then_it_includes_the_data_from_the_application_form
  end

  scenario 'A candidate is recruited in an undergraduate course' do
    given_a_provider_recruited_a_candidate_that_applied_to_an_undergraduate_course
    when_i_retrieve_the_application_over_the_api
    then_it_includes_the_empty_degrees_data_from_the_application
  end

  def given_a_provider_recruited_a_candidate_that_applied_to_a_postgraduate_course
    candidate_completes_application_form
    candidate_submits_application
    equality_and_diversity_data = {
      sex: 'male',
      ethnic_group: 'Asian or Asian British',
      ethnic_background: 'Asian or Asian British',
      disabilities: %w[learning],
      hesa_sex: 1,
      hesa_disabilities: %w[51],
      hesa_ethnicity: '39',
    }
    @application.update!(equality_and_diversity: equality_and_diversity_data)
    @provider.courses.first.update!(uuid: SecureRandom.uuid)

    and_application_is_recruited
  end

  def and_application_is_recruited
    @application.application_choices.first.update!(
      status: :recruited,
      recruited_at: Time.zone.now,
    )
  end

  def given_a_provider_recruited_a_candidate_that_applied_to_an_undergraduate_course
    given_undergraduate_courses_exist
    candidate_completes_application_form
    candidate_does_not_have_a_degree
    candidate_submits_undergraduate_application
    and_application_is_recruited
  end

  def when_i_retrieve_the_application_over_the_api
    api_token = ServiceAPIUser.register_user.create_magic_link_token!
    page.driver.header 'Authorization', "Bearer #{api_token}"

    visit "/register-api/applications?recruitment_cycle_year=#{@current_year}&since=#{CGI.escape(1.day.ago.iso8601)}"

    @api_response = JSON.parse(page.body)
  end

  def then_it_includes_the_data_from_the_application_form
    expected_attributes = {
      id: @provider.application_choices.first.id.to_s,
      type: 'application',
      attributes: {
        support_reference: @provider.application_forms.first.support_reference,
        hesa_itt_data: {
          disability: %w[51],
          ethnicity: '39',
          sex: 1,
        },
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
        candidate: {
          id: "C#{@current_candidate.id}",
          first_name: 'Lando',
          last_name: 'Calrissian',
          date_of_birth: '1990-04-06',
          nationality: %w[GB US],
          domicile: @application.domicile,
          uk_residency_status: 'UK Citizen',
          uk_residency_status_code: 'A',
          fee_payer: '02',
          english_main_language: true,
          other_languages: nil,
          english_language_qualifications: nil,
          disability_disclosure: 'I have difficulty climbing stairs',
          gender: 'male',
          disabilities: %w[learning],
          disabilities_and_health_conditions: [
            {
              hesa_code: '51',
              name: 'Dyslexia, dyspraxia or attention deficit hyperactivity disorder (ADHD) or another learning difference',
              text: nil,
              uuid: 'f9624005-d7aa-45b3-bfce-ef2e2779f631',
            },
          ],
          ethnic_group: 'Asian or Asian British',
          ethnic_background: 'Asian or Asian British',
        },
        course: {
          recruitment_cycle_year: @current_year,
          course_code: '2XT2',
          course_uuid: @provider.courses.first.uuid,
          training_provider_code: '1N1',
          training_provider_type: 'scitt',
          accredited_provider_type: nil,
          accredited_provider_code: nil,
          site_code: '-',
          study_mode: 'full_time',
        },
        qualifications: {
          gcses: [
            {
              id: @application.english_gcse.constituent_grades['english_single_award']['public_id'],
              qualification_type: 'gcse',
              non_uk_qualification_type: nil,
              subject: 'English single award',
              grade: 'B',
              start_year: nil,
              award_year: '1990',
              institution_details: nil,
              equivalency_details: nil,
              comparable_uk_degree: nil,
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
              grade: 'B',
              start_year: nil,
              award_year: '1990',
              institution_details: nil,
              equivalency_details: nil,
              comparable_uk_degree: nil,
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
              id: @application.qualification_in_subject(:degree, 'Aerospace engineering').public_id,
              non_uk_qualification_type: nil,
              subject: 'Aerospace engineering',
              subject_uuid: '9f7f70f0-5dce-e911-a985-000d3ab79618',
              qualification_type: 'Bachelor of Arts',
              degree_type_uuid: 'db695652-c197-e711-80d8-005056ac45bb',
              institution_details: 'ThinkSpace Education, GB',
              institution_uuid: '1c3f182c-1425-ec11-b6e6-000d3adf095a',
              grade: 'First class honours',
              grade_uuid: '8741765a-13d8-4550-a413-c5a860a59d25',
              start_year: '2006',
              award_year: '2009',
              equivalency_details: nil,
              comparable_uk_degree: nil,
              hesa_degclss: '01',
              hesa_degctry: 'XK',
              hesa_degenddt: '2009-01-01',
              hesa_degest: '0437',
              hesa_degsbj: '100115',
              hesa_degstdt: '2006-01-01',
              hesa_degtype: '051',
            },
          ],
          other_qualifications: [
            {
              id: @application.qualification_in_subject(:other, 'Believing in the Heart of the Cards').public_id,
              qualification_type: 'A level',
              non_uk_qualification_type: nil,
              subject: 'Believing in the Heart of the Cards',
              grade: 'A',
              start_year: nil,
              award_year: '2015',
              institution_details: nil,
              equivalency_details: nil,
              comparable_uk_degree: nil,
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
        status: 'recruited',
        recruited_at: @application.application_choices.first.recruited_at.iso8601,
        submitted_at: @application.submitted_at.iso8601,
        updated_at: @application.application_choices.first.updated_at.iso8601,
      },
    }

    expect(api_received_data.deep_sort).to eq expected_attributes.deep_sort
  end

  def then_it_includes_the_empty_degrees_data_from_the_application
    expect(api_received_data[:attributes][:qualifications][:degrees]).to eq([])
  end

  def api_received_data
    @api_response['data'].first.deep_symbolize_keys
  end
end
