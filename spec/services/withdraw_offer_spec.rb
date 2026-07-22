require 'rails_helper'

RSpec.describe WithdrawOffer do
  describe '#save!' do
    it 'changes the state of the application_choice to "rejected" given a valid reason' do
      application_choice = create(:application_choice, status: :offer)

      withdrawal_reason = 'We are so sorry...'
      described_class.new(
        actor: create(:support_user),
        application_choice:,
        offer_withdrawal_reason: withdrawal_reason,
      ).save

      expect(application_choice.reload.status).to eq 'offer_withdrawn'
    end

    it 'does not change the state of the application_choice to "rejected" without a valid reason' do
      application_choice = create(:application_choice, status: :offer)

      service = described_class.new(
        actor: create(:support_user),
        application_choice:,
      )

      expect(service.save).to be false

      expect(application_choice.reload.status).to eq 'offer'
    end

    it 'raises an error if the user is not authorised' do
      application_choice = create(:application_choice, status: :offer)
      provider_user = create(:provider_user)
      provider_user.providers << application_choice.current_course.provider

      service = described_class.new(
        actor: provider_user,
        application_choice:,
        offer_withdrawal_reason: 'We are so sorry...',
      )

      expect { service.save }.to raise_error(ProviderAuthorisation::NotAuthorisedError)

      expect(application_choice.reload.status).to eq 'offer'
    end

    it 'sends an email to the candidate' do
      allow(CandidateMailers::SendWithdrawnOfferEmailWorker).to receive(:perform_async).and_return(true)
      application_choice = create(:application_choice, status: :offer)
      withdrawal_reason = 'We messed up big time'

      described_class.new(
        actor: create(:support_user),
        application_choice:,
        offer_withdrawal_reason: withdrawal_reason,
      ).save

      expect(CandidateMailers::SendWithdrawnOfferEmailWorker).to have_received(:perform_async).with(application_choice.id)
    end
  end
end
