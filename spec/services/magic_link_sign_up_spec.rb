require 'rails_helper'

RSpec.describe MagicLinkSignUp do
  describe 'Candidate signs up' do
    let(:candidate) { create(:candidate) }

    it 'sends a Slack notification' do
      allow(SlackNotificationWorker).to receive(:perform_async)
      MagicLinkSignUp.call(candidate: candidate)
      expect(SlackNotificationWorker).to have_received(:perform_async)
    end
  end
end
