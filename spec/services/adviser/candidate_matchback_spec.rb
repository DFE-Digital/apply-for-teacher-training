require 'rails_helper'

RSpec.describe Adviser::CandidateMatchback do
  before do
    allow(GetIntoTeachingApiClient::TeacherTrainingAdviserApi).to receive(:new) { api_double }
  end

  let(:api_double) { instance_double(GetIntoTeachingApiClient::TeacherTrainingAdviserApi) }
  let(:application_form) { build(:completed_application_form, :with_domestic_adviser_qualifications) }
  let(:existing_candidate_request) do
    GetIntoTeachingApiClient::ExistingCandidateRequest.new(
      email: application_form.candidate.email_address,
      first_name: application_form.first_name,
      last_name: application_form.last_name,
      date_of_birth: application_form.date_of_birth,
    )
  end

  subject(:candidate_matchback) { described_class.new(application_form) }

  describe '#teacher_training_adviser_sign_up' do
    it 'returns candidate information when matched' do
      api_model = GetIntoTeachingApiClient::TeacherTrainingAdviserSignUp.new(candidate_id: SecureRandom.uuid)
      allow(api_double).to receive(:matchback_candidate).with(existing_candidate_request) { api_model }

      matchback_candidate = candidate_matchback.teacher_training_adviser_sign_up

      expect(matchback_candidate).to eq(api_model)
      expect(matchback_candidate).to be_an_instance_of(Adviser::TeacherTrainingAdviserSignUpDecorator)
    end

    it 'returns empty candidate information when the API responds with 404 not found' do
      not_found_error = GetIntoTeachingApiClient::ApiError.new(code: 404)
      allow(api_double).to receive(:matchback_candidate).with(existing_candidate_request).and_raise(not_found_error)

      matchback_candidate = candidate_matchback.teacher_training_adviser_sign_up

      expect(matchback_candidate).to be_an_instance_of(Adviser::TeacherTrainingAdviserSignUpDecorator)
    end

    it 're-raises when the API responds with error' do
      error = GetIntoTeachingApiClient::ApiError.new(code: 500)
      allow(api_double).to receive(:matchback_candidate).with(existing_candidate_request).and_raise(error)
      expect { candidate_matchback.teacher_training_adviser_sign_up }.to raise_error(error)
    end

    it 're-raises when the API responds with any other error' do
      error = Faraday::Error.new('Some error')
      allow(api_double).to receive(:matchback_candidate).with(existing_candidate_request).and_raise(error)
      expect { candidate_matchback.teacher_training_adviser_sign_up }.to raise_error(error)
    end
  end
end
