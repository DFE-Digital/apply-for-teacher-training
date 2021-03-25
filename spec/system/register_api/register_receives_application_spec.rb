require 'rails_helper'

# This is an end-to-end test for the API response. To test complex logic in
# the presenter, see spec/presenters/register_api/single_application_presenter_spec.rb.
RSpec.feature 'Register receives an application data', recruitment_cycle: 2020 do
  include CandidateHelper

  scenario 'A candidate is recruited' do
    Timecop.freeze do
      given_a_provider_recruited_a_candidate
      when_i_retrieve_the_application_over_the_api
      then_it_should_include_the_data_from_the_application_form
    end
  end

  def given_a_provider_recruited_a_candidate
    candidate_completes_application_form
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
    candidate_submits_application
    @application.application_choices.first.update!(
      status: :recruited,
      recruited_at: Time.zone.now,
    )
  end

  def when_i_retrieve_the_application_over_the_api
    api_token = ServiceAPIUser.register_user.create_magic_link_token!
    page.driver.header 'Authorization', "Bearer #{api_token}"

    visit "/register-api/applications?recruitment_cycle_year=#{RecruitmentCycle.current_year}"

    @api_response = JSON.parse(page.body)
  end

  def then_it_should_include_the_data_from_the_application_form
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
          gender: 'male',
          disabilities: %w[learning],
          ethnic_group: 'Asian or Asian British',
          ethnic_background: 'Asian or Asian British',
        },
        course: {
          recruitment_cycle_year: 2020,
          course_code: '2XT2',
          course_name: 'Primary',
          level: 'primary',
          subject_codes: @application.application_choices.first.course_option.course.subject_codes,
          program_type: nil,
          start_date: '2020-09',
          course_length: 'OneYear',
          age_range: '4 to 8',
          study_mode: 'full_time',
          site_code: '-',
        },
        provider: {
          provider_name: 'Gorse SCITT',
          provider_code: '1N1',
          region_code: nil,
          postcode: nil,
          provider_type: nil,
          latitude: nil,
          longitude: nil,
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
              id: @application.qualification_in_subject(:degree, 'Doge').public_id,
              qualification_type: 'BA',
              non_uk_qualification_type: nil,
              subject: 'Doge',
              grade: 'First class honours',
              start_year: '2006',
              award_year: '2009',
              institution_details: 'University of Much Wow',
              equivalency_details: nil,
              comparable_uk_degree: nil,
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
          missing_gcses_explanation: 'Science GCSE or equivalent: I will sit the exam at my local college this summer.',
        },
        status: 'recruited',
        recruited_at: @application.application_choices.first.recruited_at.iso8601,
        submitted_at: @application.submitted_at.iso8601,
        updated_at: @application.application_choices.first.updated_at.iso8601,
      },
    }

    received_attributes = @api_response['data'].first.deep_symbolize_keys
    expect(received_attributes.deep_sort).to eq expected_attributes.deep_sort
  end
end
