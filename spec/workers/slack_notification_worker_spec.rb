require 'rails_helper'

RSpec.describe SlackNotificationWorker do
  before do
    @slack_request = stub_request(:post, "https://example.com/webhook")
      .to_return(status: 200, headers: {})
  end

  describe '#perform' do
    it 'sends a Slack notification to this webhook if the URL is set' do
      ClimateControl.modify STATE_CHANGE_SLACK_URL: 'https://example.com/webhook' do
        invoke_worker
      end

      expect(@slack_request).to have_been_made
    end

    it 'does not send a Slack notification if STATE_CHANGE_SLACK_URL is empty' do
      ClimateControl.modify STATE_CHANGE_SLACK_URL: nil do
        invoke_worker
      end

      expect(@slack_request).not_to have_been_made
    end
  end

  def invoke_worker
    SlackNotificationWorker.new.perform('example text', 'https://example.com/support')
  end
end
