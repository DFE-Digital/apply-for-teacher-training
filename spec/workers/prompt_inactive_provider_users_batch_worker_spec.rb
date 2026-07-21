require 'rails_helper'

RSpec.describe PromptInactiveProviderUsersBatchWorker do
  describe '#perform' do
    before do
      mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)

      allow(ProviderMailer).to receive(:inactive_user_prompt).and_return(mail)
    end

    it 'prompts provider users in the batch' do
      provider_users = create_list(:provider_user, 2, :with_provider)

      described_class.perform_now(
        provider_users.pluck(:id),
        Date.new(2026, 1, 15),
      )

      expect(ProviderMailer).to have_received(:inactive_user_prompt).with(
        provider_users[0],
        Date.new(2026, 1, 15),
      )

      expect(ProviderMailer).to have_received(:inactive_user_prompt).with(
        provider_users[1],
        Date.new(2026, 1, 15),
      )
    end
  end
end
