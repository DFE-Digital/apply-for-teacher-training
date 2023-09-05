require 'rails_helper'

RSpec.describe 'GET /candidate-api/v1.3/candidates' do
  include CandidateAPISpecHelper

  let(:root_path) { '/candidate-api/v1.3/candidates' }

  it_behaves_like 'an API endpoint requiring a date param', '/candidate-api/v1.3/candidates', 'updated_since', ServiceAPIUser.candidate_user.create_magic_link_token!
  it_behaves_like 'a candidate API endpoint', '/candidate-api/v1.3/candidates', 'updated_since', 'v1.3'

  it 'returns candidates ordered by `updated_at` timestamp desc across multiple associations, with applications ordered by `created_at` asc' do
    allow(ApplicationFormStateInferrer).to receive(:new).and_return(instance_double(ApplicationFormStateInferrer, state: :unsubmitted_not_started_form))

    candidate = create(:candidate)
    application_forms = []

    application_forms << create(:completed_application_form, submitted_application_choices_count: 3, candidate:)

    get_api_request "#{root_path}?updated_since=#{CGI.escape(1.day.ago.iso8601)}", token: candidate_api_token

    response_data = parsed_response.dig('data', 0, 'attributes', 'application_forms')

    expect(response_data.size).to eq(1)

    first_application_choice = application_forms.first.application_choices.first

    expect(response_data.first['id']).to eq(application_forms.first.id)
    expect(response_data.first['application_phase']).to eq(application_forms.first.phase)
    expect(response_data.first['application_status']).to eq(ApplicationFormStateInferrer.new(application_forms.first).state.to_s)
    expect(response_data.first['recruitment_cycle_year']).to eq(application_forms.first.recruitment_cycle_year)
    expect(response_data.first['submitted_at']).to eq(application_forms.first.submitted_at.iso8601)
    expect(response_data.first['application_choices']['completed']).to be_nil
    expect(response_data.first['application_choices']['data'].first['sent_to_provider_at']).to eq(first_application_choice.sent_to_provider_at.iso8601)
    expect(response_data.first['application_choices']['data'].count).to eq(3)
    expect(response_data.first['application_choices']['data'].first['status']).to eq(first_application_choice.status)
  end
end
