require 'rails_helper'

RSpec.describe SlackNotificationWorker do
  include TestHelpers::LoggingHelper
  let(:rails_config) { environment_config_double }

  describe 'SlackNotificationWorker' do
    let(:text) { 'example text' }
    let(:url) { 'https://example.com/support' }
    let(:output) { capture_logstash_output(rails_config) { invoke_worker } }

    before { allow(HTTP).to receive(:post) }

    def invoke_worker
      SlackNotificationWorker.new.perform(text, url)
    end

    it 'logs it has run to the default Rails logger' do
      expect(output).not_to be_blank
    end

    it 'includes the text supplied in the log' do
      expect(output).to match(text)
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

      it 'warns about Slack notification failures in the logs' do
        # allow(HTTP).to receive(:post).and_raise(StandardError)
        ClimateControl.modify STATE_CHANGE_SLACK_URL: webhook_url do
          expect(output).to match(/Notification to slack failed/)
        end
      end

      it 'includes hyperlinked text, a username and an emoji' do
        ClimateControl.modify STATE_CHANGE_SLACK_URL: webhook_url do
          invoke_worker
        end
        expect(HTTP).to have_received(:post).with \
          'https://example.com/webhook',
          body: '{"username":"ApplyBot","icon_emoji":":parrot:","text":"[TEST] \u003chttps://example.com/support|example text\u003e","mrkdwn":true}'
      end
    end
  end
end
