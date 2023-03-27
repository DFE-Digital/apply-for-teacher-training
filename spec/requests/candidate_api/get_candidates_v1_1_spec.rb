require 'rails_helper'

RSpec.describe 'GET /candidate-api/v1.1/candidates' do
  include CandidateAPISpecHelper

  let(:root_path) { '/candidate-api/v1.1/candidates' }

  it_behaves_like 'an API endpoint requiring a date param', '/candidate-api/v1.1/candidates', 'updated_since', ServiceAPIUser.candidate_user.create_magic_link_token!
  it_behaves_like 'a candidate API endpoint', '/candidate-api/v1.1/candidates', 'updated_since', 'v1.1'

  it 'returns applications ordered by created_at timestamp' do
    allow(ApplicationFormStateInferrer).to receive(:new).and_return(instance_double(ApplicationFormStateInferrer, state: :unsubmitted_not_started_form))

    candidate = create(:candidate)
    application_forms = []

    application_forms << create(:completed_application_form, candidate:)
    TestSuiteTimeMachine.advance
    application_forms << create(:completed_application_form, candidate:)

    get_api_request "/candidate-api/v1.1/candidates?updated_since=#{CGI.escape(1.day.ago.iso8601)}", token: candidate_api_token

    response_data = parsed_response.dig('data', 0, 'attributes', 'application_forms')

    expect(response_data.size).to eq(2)

    expect(response_data.first['id']).to eq(application_forms.first.id)
    expect(response_data.first['application_phase']).to eq(application_forms.first.phase)
    expect(response_data.first['application_status']).to eq(ApplicationFormStateInferrer.new(application_forms.first).state.to_s)
    expect(response_data.first['recruitment_cycle_year']).to eq(application_forms.first.recruitment_cycle_year)
    expect(response_data.first['submitted_at']).to eq(application_forms.first.submitted_at.iso8601)

    expect(response_data.second['id']).to eq(application_forms.second.id)
    expect(response_data.second['application_phase']).to eq(application_forms.second.phase)
    expect(response_data.second['application_status']).to eq(ApplicationFormStateInferrer.new(application_forms.second).state.to_s)
    expect(response_data.second['recruitment_cycle_year']).to eq(application_forms.second.recruitment_cycle_year)
    expect(response_data.second['submitted_at']).to eq(application_forms.second.submitted_at.iso8601)
  end
end
