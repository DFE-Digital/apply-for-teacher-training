require 'rails_helper'

RSpec.describe SlackNotificationWorker do
  include TestHelpers::LoggingHelper
  let(:rails_config) { environment_config_double }

  describe 'SlackNotificationWorker' do
    let(:text) { 'example text' }
    let(:url) { 'https://example.com/support' }
    let(:output) { capture_logstash_output(rails_config) { invoke_worker } }

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
      stub_const('SlackNotificationWorker::INCOMING_WEBHOOK_URL', nil)
      expect(HTTP).not_to receive(:post)
      invoke_worker
    end

    context 'when STATE_CHANGE_SLACK_URL is set' do
      before do
        stub_const('SlackNotificationWorker::INCOMING_WEBHOOK_URL', 'https://example.com/webhook')
      end

      it 'sends a Slack notification to this webhook' do
        expect(HTTP).to receive(:post)
        invoke_worker
      end

      it 'warns about Slack notification failures in the logs' do
        allow(HTTP).to receive(:post).and_raise(StandardError)
        expect(output).to match(/Notification to slack failed/)
      end

      it 'includes hyperlinked text, a username and an emoji' do
        expect(HTTP).to receive(:post).with \
          'https://example.com/webhook',
          body: '{"username":"ApplyBot","icon_emoji":":parrot:","text":"\u003chttps://example.com/support|example text\u003e","mrkdwn":true}'
        invoke_worker
      end
    end
  end
end
