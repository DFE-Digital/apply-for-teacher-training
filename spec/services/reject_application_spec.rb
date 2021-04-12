require 'rails_helper'

RSpec.describe RejectApplication do
  describe 'validations' do
    let(:provider_user) { build_stubbed(:provider_user) }
    let(:application_choice) { build_stubbed(:application_choice) }

    subject(:invalid_service) { described_class.new(actor: provider_user, application_choice: application_choice) }

    it 'validates rejection_reason and structured_rejection_reasons' do
      expect(invalid_service.valid?).to be false
      expect(invalid_service.errors.attribute_names.sort).to eq(%i[rejection_reason])
    end
  end

  describe '#save' do
    let(:provider_user) { create(:provider_user) }
    let(:application_choice) { create(:submitted_application_choice) }
    let(:auth) { instance_double(ProviderAuthorisation, assert_can_make_decisions!: true, actor: provider_user) }

    subject(:service) { described_class.new(actor: provider_user, application_choice: application_choice, rejection_reason: 'wrong') }

    before { allow(ProviderAuthorisation).to receive(:new).and_return(auth) }

    it 'checks the actor can make decisions on the application' do
      allow(auth).to receive(:assert_can_make_decisions!).and_raise(ProviderAuthorisation::NotAuthorisedError)

      expect { service.save }.to raise_error(ProviderAuthorisation::NotAuthorisedError)
    end

    it 'updates the state of the application' do
      service.save

      expect(application_choice.status).to eq('rejected')
    end

    it 'updates the rejection reason on the application' do
      service.save

      expect(application_choice.rejection_reason).to eq('wrong')
    end

    it 'updates the structured rejection reasons on the application' do
      reasons_for_rejection_attrs = {
        candidate_behaviour_y_n: 'Yes',
        candidate_behaviour_what_did_the_candidate_do: %w[other],
        candidate_behaviour_other: 'Bad language',
        candidate_behaviour_what_to_improve: 'Do not swear',
      }
      service = described_class.new(
        actor: provider_user,
        application_choice: application_choice,
        structured_rejection_reasons: ReasonsForRejection.new(reasons_for_rejection_attrs),
      )

      service.save

      expect(application_choice.structured_rejection_reasons.symbolize_keys).to eq(reasons_for_rejection_attrs)
    end

    it 'emails the candidate' do
      email_service = instance_double(SendCandidateRejectionEmail, call: true)
      allow(SendCandidateRejectionEmail).to receive(:new).and_return(email_service)

      service.save

      expect(SendCandidateRejectionEmail).to have_received(:new).with(application_choice: application_choice)
      expect(email_service).to have_received(:call)
    end

    it 'sends a Slack notification if all candidate applications have ended without success' do
      notifier = instance_double(StateChangeNotifier, application_outcome_notification: nil)
      allow(StateChangeNotifier).to receive(:new).and_return(notifier)

      service.save

      expect(StateChangeNotifier).to have_received(:new).with(:rejected, application_choice)
      expect(notifier).to have_received(:application_outcome_notification)
    end

    it 'returns true if the call was successful' do
      expect(service.save).to be true
    end

    it 'returns false if the call was unsuccessful' do
      allow(application_choice).to receive(:update!).and_raise(Workflow::NoTransitionAllowed)

      expect(service.save).to be false
    end
  end
end
