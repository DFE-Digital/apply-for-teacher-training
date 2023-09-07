require 'rails_helper'

RSpec.describe 'GET /candidate-api/v1.2/candidates' do
  include CandidateAPISpecHelper

  let(:root_path) { '/candidate-api/v1.2/candidates' }

  it_behaves_like 'an API endpoint requiring a date param', '/candidate-api/v1.2/candidates', 'updated_since', ServiceAPIUser.candidate_user.create_magic_link_token!
  it_behaves_like 'a candidate API endpoint', '/candidate-api/v1.2/candidates', 'updated_since', 'v1.2'

  it 'returns candidates ordered by `updated_at` timestamp desc across multiple associations, with applications ordered by `created_at` asc', time: '2023-11-04 09:00:00' do
    allow(ApplicationFormStateInferrer).to receive(:new).and_return(instance_double(ApplicationFormStateInferrer, state: :unsubmitted_not_started_form))

    application_forms = []
    last_updated_at_for_first_candidate = nil

    create(:candidate).tap do |candidate|
      # Created/updated first, within cut-off
      application_forms << create(:application_form, :with_completed_references, application_choices_count: 3, candidate:).tap do |form|
        create(
          :interview,
          date_and_time: 2.weeks.from_now,
          application_choice: form.application_choices.first,
          skip_application_choice_status_update: true,
        )
      end
      advance_time

      # Created/updated second, within cut-off
      application_forms << create(:application_form, :with_completed_references, application_choices_count: 3, candidate:)
      last_updated_at_for_first_candidate = Time.zone.now
      advance_time
    end

    # Created a month ago (outside of cut-off)
    travel_temporarily_to(1.month.ago) do
      application_forms << create(:application_form, :with_completed_references, application_choices_count: 3)
    end
    advance_time

    # Created a month ago (outside of cut-off) but updated within cut-off
    travel_temporarily_to(1.month.ago) do
      application_forms << create(:completed_application_form)
    end
    application_forms.last.touch
    advance_time

    # Created a month ago (outside of cut-off) but application choice updated within cut-off
    travel_temporarily_to(1.month.ago) do
      application_forms << create(:completed_application_form, application_choices_count: 1)
    end
    application_forms.last.application_choices.first.touch
    advance_time

    # Created a month ago (outside of cut-off) but reference updated within cut-off
    travel_temporarily_to(1.month.ago) do
      application_forms << create(:application_form, :with_completed_references, references_state: :feedback_requested)
    end
    application_forms.last.application_references.first.update(feedback_status: :feedback_provided)
    advance_time

    get_api_request "#{root_path}?updated_since=#{CGI.escape(1.day.ago.iso8601)}", token: candidate_api_token

    candidate_data = parsed_response.fetch('data').map { |c| c.fetch('attributes') }

    expect(candidate_data.size).to eq(4)
    expect(candidate_data.first['updated_at']).to eq(last_updated_at_for_first_candidate.iso8601)

    application_data = candidate_data.flat_map { |c| c.fetch('application_forms') }
    expect(application_data.size).to eq(5)

    first_application_choice = application_forms.first.application_choices.first
    first_reference = application_forms.first.application_references.creation_order.first

    expect(application_data.first['id']).to eq(application_forms.first.id)
    expect(application_data.first['application_phase']).to eq(application_forms.first.phase)
    expect(application_data.first['application_status']).to eq(ApplicationFormStateInferrer.new(application_forms.first).state.to_s)
    expect(application_data.first['recruitment_cycle_year']).to eq(application_forms.first.recruitment_cycle_year)
    expect(application_data.first['submitted_at']).to eq(application_forms.first.submitted_at.iso8601)
    expect(application_data.first['application_choices']['completed']).to be(true)
    expect(application_data.first['application_choices']['data'].count).to eq(3)
    expect(application_data.first['application_choices']['data'].first['status']).to eq(first_application_choice.status)
    expect(application_data.first['application_choices']['data'].first['provider']&.symbolize_keys).to eq({
      name: first_application_choice.provider.name,
    })
    expect(application_data.first['application_choices']['data'].first['course']&.symbolize_keys).to eq({
      uuid: first_application_choice.course.uuid,
      name: first_application_choice.course.name,
    })
    expect(application_data.first['application_choices']['data'].first['interviews'].first&.symbolize_keys).to include(
      {
        id: first_application_choice.interviews.first.id,
        date_and_time: first_application_choice.interviews.first.date_and_time.iso8601,
      },
    )
    expect(application_data.first['qualifications']['completed']).to be(true)
    expect(application_data.first['personal_statement']['completed']).to be(true)
    expect(application_data.first['references']['completed']).to be(true)
    expect(application_data.first['references']['data'].count).to be(2)
    expect(application_data.first['references']['data'].first.symbolize_keys).to eq(
      {
        id: first_reference.id,
        requested_at: first_reference.requested_at.iso8601,
        feedback_status: first_reference.feedback_status,
        referee_type: first_reference.referee_type,
        created_at: first_reference.created_at.iso8601,
        updated_at: first_reference.updated_at.iso8601,
      },
    )

    expect(application_data.second['id']).to eq(application_forms.second.id)
    expect(application_data.second['application_phase']).to eq(application_forms.second.phase)
    expect(application_data.second['application_status']).to eq(ApplicationFormStateInferrer.new(application_forms.second).state.to_s)
    expect(application_data.second['recruitment_cycle_year']).to eq(application_forms.second.recruitment_cycle_year)
    expect(application_data.second['submitted_at']).to eq(application_forms.second.submitted_at.iso8601)
    expect(application_data.second['application_choices']['completed']).to be(true)
    expect(application_data.second['application_choices']['data'].count).to eq(3)
  end
end
