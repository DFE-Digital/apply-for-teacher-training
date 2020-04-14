require 'rails_helper'

RSpec.describe SlackNotificationWorker do
  include TestHelpers::LoggingHelper
  let(:rails_config) { environment_config_double }

  describe 'SlackNotificationWorker' do
    let(:text) { 'example text' }
    let(:url) { 'https://example.com/support' }

    around do |example|
      ClimateControl.modify HOSTING_ENVIRONMENT_NAME: 'TEST' do
        example.run
      end
    end

    before { allow(HTTP).to receive(:post) }

    def invoke_worker
      SlackNotificationWorker.new.perform(text, url)
    end

    it 'does not send a Slack notification if STATE_CHANGE_SLACK_URL is empty' do
      ClimateControl.modify STATE_CHANGE_SLACK_URL: nil do invoke_worker end
      expect(HTTP).not_to have_received(:post)
    end

    context 'when STATE_CHANGE_SLACK_URL is set' do
      let(:webhook_url) { 'https://example.com/webhook' }

      it 'sends a Slack notification to this webhook' do
        ClimateControl.modify STATE_CHANGE_SLACK_URL: webhook_url do
          invoke_worker
        end
        expect(HTTP).to have_received(:post)
      end

      it 'includes hyperlinked text, a username and an emoji' do
        ClimateControl.modify STATE_CHANGE_SLACK_URL: webhook_url do
          invoke_worker
        end

        expect(HTTP).to have_received(:post).with(
          'https://example.com/webhook',
          body: '{"username":"Apply for teacher training","icon_emoji":":shipitbeaver:","channel":"#twd_apply_test","text":"[TEST] \u003chttps://example.com/support|example text\u003e","mrkdwn":true}',
        )
      end
    end
  end
end
