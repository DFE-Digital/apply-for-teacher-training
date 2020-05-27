require 'rails_helper'

RSpec.describe MagicLinkSignUp do
  describe 'Candidate signs up' do
    it 'sends a Slack notification every 5 signups' do
      allow(SlackNotificationWorker).to receive(:perform_async)

      create_list(:candidate, 3)
      MagicLinkSignUp.call(candidate: create(:candidate))

      expect(SlackNotificationWorker).not_to have_received(:perform_async)

      MagicLinkSignUp.call(candidate: create(:candidate))

      expect(SlackNotificationWorker).to have_received(:perform_async)
    end
  end
end
