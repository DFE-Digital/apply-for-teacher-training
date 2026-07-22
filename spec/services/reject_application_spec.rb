require 'rails_helper'

RSpec.describe RejectApplication do
  describe 'validations' do
    let(:provider_user) { build_stubbed(:provider_user) }
    let(:application_choice) { build_stubbed(:application_choice) }

    subject(:invalid_service) { described_class.new(actor: provider_user, application_choice:) }

    it 'validates rejection_reason and structured_rejection_reasons' do
      expect(invalid_service.valid?).to be false
      expect(invalid_service.errors.attribute_names.sort).to eq(%i[rejection_reason])
    end
  end

  describe '#save' do
    let(:provider_user) { create(:provider_user) }
    let(:application_choice) { create(:application_choice, :awaiting_provider_decision) }
    let(:auth) { instance_double(ProviderAuthorisation, assert_can_make_decisions!: true, actor: provider_user) }

    subject(:service) { described_class.new(actor: provider_user, application_choice:, rejection_reason: 'wrong') }

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
      expect(application_choice.rejection_reasons_type).to eq('rejection_reason')
    end

    it 'updates the structured rejection reasons on the application' do
      rejection_reasons_attrs = {
        selected_reasons: [
          { id: 'qualifications', label: 'Qualifications', selected_reasons: [
            { id: 'no_maths_gcse', label: 'No Maths GCSE' },
            { id: 'no_science_gcse', label: 'No Science GCSE' },
          ] },
          { id: 'course_full', label: 'Course full' },
        ],
      }

      service = described_class.new(
        actor: provider_user,
        application_choice:,
        structured_rejection_reasons: RejectionReasons.new(rejection_reasons_attrs),
      )

      service.save

      expect(application_choice.structured_rejection_reasons.deep_symbolize_keys).to eq(rejection_reasons_attrs)
      expect(application_choice.rejection_reasons_type).to eq('rejection_reasons')
    end

    it 'emails the candidate' do
      allow(CandidateMailers::SendRejectionEmailWorker).to receive(:perform_async).and_return(true)

      service.save

      expect(CandidateMailers::SendRejectionEmailWorker).to have_received(:perform_async).with(application_choice.id)
    end

    it 'returns true if the call was successful' do
      expect(service.save).to be true
    end

    it 'returns false if the call was unsuccessful' do
      allow(application_choice).to receive(:update!).and_raise(Workflow::NoTransitionAllowed)

      expect(service.save).to be false
    end

    it 'calls the CancelUpcomingInterviews service' do
      cancel_upcoming_interviews = instance_double(CancelUpcomingInterviews, call!: true)

      allow(CancelUpcomingInterviews)
        .to receive(:new).with(actor: provider_user, application_choice:, cancellation_reason: 'Your application was unsuccessful.')
                         .and_return(cancel_upcoming_interviews)
      service.save
      expect(cancel_upcoming_interviews).to have_received(:call!)
    end
  end
end
