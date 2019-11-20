require 'rails_helper'

RSpec.describe MagicLinkSignUp do
  describe 'Candidate signs up' do
    let(:candidate) { create(:candidate) }

    it 'sends a Slack notification' do
      expect(SlackNotificationWorker).to receive(:perform_async)

      MagicLinkSignUp.call(candidate: candidate)
    end
  end
end
