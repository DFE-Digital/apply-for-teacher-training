require 'rails_helper'

RSpec.describe 'GET /candidate-api/v1.2/candidates', type: :request do
  include CandidateAPISpecHelper

  let(:root_path) { '/candidate-api/v1.2/candidates' }

  it_behaves_like 'an API endpoint requiring a date param', '/candidate-api/v1.2/candidates', 'updated_since', ServiceAPIUser.candidate_user.create_magic_link_token!
  it_behaves_like 'a candidate API endpoint', '/candidate-api/v1.2/candidates', 'updated_since'

  it 'returns applications ordered by created_at timestamp' do
    allow(ProcessState).to receive(:new).and_return(instance_double(ProcessState, state: :unsubmitted_not_started_form))

    candidate = create(:candidate)
    application_forms = create_list(
      :completed_application_form,
      2,
      :with_completed_references,
      candidate: candidate,
      application_choices_count: 3,
    )

    first_application_choice = application_forms.first.application_choices.first
    first_reference = application_forms.first.application_references.first

    create(
      :interview,
      date_and_time: Time.zone.local(2022, 6, 1, 10, 0, 0),
      application_choice: first_application_choice,
      skip_application_choice_status_update: true,
    )

    get_api_request "#{root_path}?updated_since=#{CGI.escape(1.day.ago.iso8601)}", token: candidate_api_token

    response_data = parsed_response.dig('data', 0, 'attributes', 'application_forms')

    expect(response_data.size).to eq(2)

    expect(response_data.first['id']).to eq(application_forms.first.id)
    expect(response_data.first['application_phase']).to eq(application_forms.first.phase)
    expect(response_data.first['application_status']).to eq(ProcessState.new(application_forms.first).state.to_s)
    expect(response_data.first['recruitment_cycle_year']).to eq(application_forms.first.recruitment_cycle_year)
    expect(response_data.first['submitted_at']).to eq(application_forms.first.submitted_at.iso8601)
    expect(response_data.first['application_choices']['completed']).to be(true)
    expect(response_data.first['application_choices']['data'].count).to eq(3)
    expect(response_data.first['application_choices']['data'].first['status']).to eq(first_application_choice.status)
    expect(response_data.first['application_choices']['data'].first['provider']&.symbolize_keys).to eq({
      name: first_application_choice.provider.name,
    })
    expect(response_data.first['application_choices']['data'].first['course']&.symbolize_keys).to eq({
      uuid: first_application_choice.course.uuid,
      name: first_application_choice.course.name,
    })
    expect(response_data.first['application_choices']['data'].first['interviews'].first&.symbolize_keys).to include(
      {
        id: first_application_choice.interviews.first.id,
        date_and_time: first_application_choice.interviews.first.date_and_time.iso8601,
      },
    )
    expect(response_data.first['qualifications']['completed']).to be(true)
    expect(response_data.first['personal_statement']['completed']).to be(true)
    expect(response_data.first['references']['completed']).to be(true)
    expect(response_data.first['references']['data'].count).to be(2)
    expect(response_data.first['references']['data'].first.symbolize_keys).to eq(
      {
        id: first_reference.id,
        requested_at: first_reference.requested_at.iso8601,
        feedback_status: first_reference.feedback_status,
        referee_type: first_reference.referee_type,
      },
    )

    expect(response_data.second['id']).to eq(application_forms.second.id)
    expect(response_data.second['application_phase']).to eq(application_forms.second.phase)
    expect(response_data.second['application_status']).to eq(ProcessState.new(application_forms.second).state.to_s)
    expect(response_data.second['recruitment_cycle_year']).to eq(application_forms.second.recruitment_cycle_year)
    expect(response_data.second['submitted_at']).to eq(application_forms.second.submitted_at.iso8601)
    expect(response_data.second['application_choices']['completed']).to be(true)
    expect(response_data.second['application_choices']['data'].count).to eq(3)
  end
end
