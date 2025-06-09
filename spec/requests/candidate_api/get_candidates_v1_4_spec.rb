require 'rails_helper'

RSpec.describe 'GET /candidate-api/v1.4/candidates' do
  include CandidateAPISpecHelper

  let(:root_path) { '/candidate-api/v1.4/candidates' }

  it_behaves_like 'an API endpoint requiring a date param', '/candidate-api/v1.4/candidates', 'updated_since', ServiceAPIUser.candidate_user.create_magic_link_token!
  it_behaves_like 'a candidate API endpoint', '/candidate-api/v1.4/candidates', 'updated_since', 'v1.4'

  it 'returns candidates ordered by `updated_at` timestamp desc across multiple associations, with applications ordered by `created_at` asc' do
    allow(ApplicationFormStateInferrer).to receive(:new).and_return(instance_double(ApplicationFormStateInferrer, state: :unsubmitted_not_started_form))

    application_form = create(:completed_application_form,
                              :completed,
                              first_name: 'John',
                              last_name: 'Doe')

    course_option = create(:course_option, course: create(:course,
                                                          level: 'secondary',
                                                          funding_type: 'fee',
                                                          program_type: 'higher_education_salaried_programme'))
    application_choice = create(:application_choice, :awaiting_provider_decision, application_form:, course_option: course_option)

    get_api_request "#{root_path}?updated_since=#{CGI.escape(1.day.ago.iso8601)}", token: candidate_api_token

    application_forms_from_response_data = parsed_response.dig('data', 0, 'attributes', 'application_forms')

    expect(application_forms_from_response_data.size).to eq(1)

    expect(application_forms_from_response_data.dig(0, 'id')).to eq(application_form.id)
    expect(application_forms_from_response_data.dig(0, 'first_name')).to eq('John')
    expect(application_forms_from_response_data.dig(0, 'last_name')).to eq('Doe')

    expect(application_forms_from_response_data.dig(0, 'application_choices', 'data', 0, 'id')).to eq(application_choice.id)
    expect(application_forms_from_response_data.dig(0, 'application_choices', 'data', 0, 'course', 'level')).to eq('secondary')
    expect(application_forms_from_response_data.dig(0, 'application_choices', 'data', 0, 'course', 'funding_type')).to eq('fee')
    expect(application_forms_from_response_data.dig(0, 'application_choices', 'data', 0, 'course', 'program_type')).to eq('higher_education_salaried_programme')
  end
end
