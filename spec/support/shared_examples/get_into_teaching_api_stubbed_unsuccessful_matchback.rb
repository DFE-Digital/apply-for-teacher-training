RSpec.shared_context 'get into teaching api stubbed unsuccessful matchback' do
  before do
    allow_any_instance_of(GetIntoTeachingApiClient::TeacherTrainingAdviserApi)
      .to receive(:matchback_candidate)
        .with(existing_candidate_request)
        .and_raise(GetIntoTeachingApiClient::ApiError.new(code: 404))
  end

  let(:existing_candidate_request) do
    GetIntoTeachingApiClient::ExistingCandidateRequest.new(
      email: application_form.candidate.email_address,
      first_name: application_form.first_name,
      last_name: application_form.last_name,
      date_of_birth: application_form.date_of_birth,
    )
  end
end
