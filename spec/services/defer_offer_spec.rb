require 'rails_helper'

RSpec.describe DeferOffer do
  describe '#save!' do
    it 'changes the state of an accepted offer to "offer_deferred"' do
      application_choice = create(:application_choice, :with_accepted_offer)

      described_class.new(
        actor: create(:support_user),
        application_choice: application_choice,
      ).save!

      expect(application_choice.reload.status).to eq 'offer_deferred'
    end

    it 'sets offer_deferred_at' do
      application_choice = create(:application_choice, :with_accepted_offer)

      described_class.new(
        actor: create(:support_user),
        application_choice: application_choice,
      ).save!

      expect(application_choice.reload.offer_deferred_at).not_to be_nil
    end

    it 'changes the state of a recruited application choice to "offer_deferred"' do
      application_choice = create(:application_choice, :with_recruited)

      described_class.new(
        actor: create(:support_user),
        application_choice: application_choice,
      ).save!

      expect(application_choice.reload.status).to eq 'offer_deferred'
    end

    it 'raises an error if the user is not authorised' do
      application_choice = create(:application_choice, :with_accepted_offer)
      provider_user = create(:provider_user)
      provider_user.providers << application_choice.current_course.provider

      service = described_class.new(
        actor: provider_user,
        application_choice: application_choice,
      )

      expect { service.save! }.to raise_error(ProviderAuthorisation::NotAuthorisedError)

      expect(application_choice.reload.status).to eq 'pending_conditions'
    end

    it 'sends the candidate an explanatory email' do
      application_choice = create(:application_choice, :with_recruited)
      deliverer = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      allow(CandidateMailer).to receive(:deferred_offer).and_return(deliverer)

      described_class.new(actor: create(:support_user), application_choice: application_choice).save!

      expect(CandidateMailer).to have_received(:deferred_offer).once.with(application_choice)
    end

    it 'notifies on the state change' do
      application_choice = create(:application_choice, :with_recruited)
      allow(StateChangeNotifier).to receive(:call)

      described_class.new(actor: create(:support_user), application_choice: application_choice).save!

      expect(StateChangeNotifier).to have_received(:call).with(:defer_offer, application_choice: application_choice)
    end
  end
end
