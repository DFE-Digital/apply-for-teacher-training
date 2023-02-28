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

  describe '#matchback' do
    it 'returns candidate information when matched' do
      matching_candidate = GetIntoTeachingApiClient::TeacherTrainingAdviserSignUp.new(candidate_id: SecureRandom.uuid)
      allow(api_double).to receive(:matchback_candidate).with(existing_candidate_request) { matching_candidate }
      expect(candidate_matchback.matchback).to eq(matching_candidate)
    end

    it 'returns nil when the API responds with 404 not found' do
      not_found_error = GetIntoTeachingApiClient::ApiError.new(code: 404)
      allow(api_double).to receive(:matchback_candidate).with(existing_candidate_request).and_raise(not_found_error)
      expect(candidate_matchback.matchback).to be_nil
    end

    it 're-raises when the API responds with any other error' do
      error = GetIntoTeachingApiClient::ApiError.new(code: 500)
      allow(api_double).to receive(:matchback_candidate).with(existing_candidate_request).and_raise(error)
      expect { candidate_matchback.matchback }.to raise_error(error)
    end
  end
end
