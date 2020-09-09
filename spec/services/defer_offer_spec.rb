require 'rails_helper'

RSpec.describe DeferOffer do
  describe '#save!' do
    it 'changes the state of an accepted offer to "offer_deferred"' do
      application_choice = create(:application_choice, :with_accepted_offer)

      DeferOffer.new(
        actor: create(:support_user),
        application_choice: application_choice,
      ).save

      expect(application_choice.reload.status).to eq 'offer_deferred'
    end

    it 'sets offer_deferred_at' do
      application_choice = create(:application_choice, :with_accepted_offer)

      DeferOffer.new(
        actor: create(:support_user),
        application_choice: application_choice,
      ).save

      expect(application_choice.reload.offer_deferred_at).not_to be_nil
    end

    it 'changes the state of a recruited application choice to "offer_deferred"' do
      application_choice = create(:application_choice, :with_recruited)

      DeferOffer.new(
        actor: create(:support_user),
        application_choice: application_choice,
      ).save

      expect(application_choice.reload.status).to eq 'offer_deferred'
    end

    it 'raises an error if the user is not authorised' do
      application_choice = create(:application_choice, :with_accepted_offer)
      provider_user = create(:provider_user)
      provider_user.providers << application_choice.offered_course.provider

      FeatureFlag.activate(:providers_can_manage_users_and_permissions)

      service = DeferOffer.new(
        actor: provider_user,
        application_choice: application_choice,
      )

      expect { service.save }.to raise_error(ProviderAuthorisation::NotAuthorisedError)

      expect(application_choice.reload.status).to eq 'pending_conditions'
    end
  end
end
