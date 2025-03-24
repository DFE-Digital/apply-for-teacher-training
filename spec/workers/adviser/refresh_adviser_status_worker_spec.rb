require 'rails_helper'

RSpec.describe Adviser::RefreshAdviserStatusWorker do
  before do
    FeatureFlag.activate(:adviser_sign_up)
  end

  describe '#perform' do
    it 'updates the adviser status from the GIT API (matchback)' do
      stub_matchback_with_adviser_status('assigned')
      application_form = create(:application_form, adviser_status: 'unassigned')

      described_class.new.perform(application_form.id)

      expect(application_form.reload.adviser_status).to eq('assigned')
    end

    context 'when the matchback status is unassigned' do
      it 'does not update the adviser status' do
        stub_matchback_with_adviser_status('unassigned')

        waiting_to_be_assigned_application_form = create(:application_form, adviser_status: 'waiting_to_be_assigned')
        assigned_application_form = create(:application_form, adviser_status: 'assigned')
        previously_assigned_application_form = create(:application_form, adviser_status: 'previously_assigned')

        described_class.new.perform(waiting_to_be_assigned_application_form.id)
        described_class.new.perform(assigned_application_form.id)
        described_class.new.perform(previously_assigned_application_form.id)

        expect(waiting_to_be_assigned_application_form.reload.adviser_status).to eq('waiting_to_be_assigned')
        expect(assigned_application_form.reload.adviser_status).to eq('assigned')
        expect(previously_assigned_application_form.reload.adviser_status).to eq('previously_assigned')
      end
    end

    context 'when the feature flag is not active' do
      before do
        FeatureFlag.deactivate(:adviser_sign_up)
      end

      it 'does not update the adviser status' do
        stub_matchback_with_adviser_status('assigned')
        application_form = create(:application_form, adviser_status: 'unassigned')

        described_class.new.perform(application_form.id)

        expect(application_form.reload.adviser_status).to eq('unassigned')
      end
    end

    context 'when the matchback API call errors' do
      it 'does not update the adviser status' do
        stub_matchback_with_error
        application_form = create(:application_form, adviser_status: 'unassigned')

        described_class.new.perform(application_form.id)

        expect(application_form.reload.adviser_status).to eq('unassigned')
      end
    end
  end

private

  def stub_matchback_with_adviser_status(status)
    assignment_status_id = Adviser::Constants.fetch(:adviser_status, status)
    matchback_candidate = GetIntoTeachingApiClient::TeacherTrainingAdviserSignUp.new(assignment_status_id:)
    teacher_training_adviser_sign_up = Adviser::TeacherTrainingAdviserSignUpDecorator.new(matchback_candidate)

    matchback_double = instance_double(Adviser::CandidateMatchback, teacher_training_adviser_sign_up:)
    allow(Adviser::CandidateMatchback).to receive(:new).and_return(matchback_double)
  end

  def stub_matchback_with_error
    matchback_double = instance_double(Adviser::CandidateMatchback)

    allow(matchback_double).to receive(:teacher_training_adviser_sign_up).and_raise(GetIntoTeachingApiClient::ApiError)
    allow(Adviser::CandidateMatchback).to receive(:new).and_return(matchback_double)
  end
end
