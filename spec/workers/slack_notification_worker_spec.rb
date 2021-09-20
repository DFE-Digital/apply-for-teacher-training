require 'rails_helper'

RSpec.describe SlackNotificationWorker do
  describe '#perform' do
    it 'sends a Slack notification to this webhook if the URL is set' do
      slack_request = stub_request(:post, 'https://example.com/webhook')
        .to_return(status: 200, headers: {})

      ClimateControl.modify STATE_CHANGE_SLACK_URL: 'https://example.com/webhook' do
        invoke_worker
      end

      expect(slack_request).to have_been_made
    end

    it 'does not send a Slack notification if STATE_CHANGE_SLACK_URL is empty' do
      slack_request = stub_request(:post, 'https://example.com/webhook')
        .to_return(status: 200, headers: {})

      ClimateControl.modify STATE_CHANGE_SLACK_URL: nil do
        invoke_worker
      end

      expect(slack_request).not_to have_been_made
    end

    it 'raises an error if Slack responds with one' do
      stub_request(:post, 'https://example.com/webhook')
        .to_return(status: 400, headers: {})

      ClimateControl.modify STATE_CHANGE_SLACK_URL: 'https://example.com/webhook' do
        expect { invoke_worker }.to raise_error(SlackNotificationWorker::SlackMessageError)
      end
    end

    it 'includes a link if given' do
      slack_request = stub_request(:post, 'https://example.com/webhook')
        .to_return(status: 200, headers: {})

      ClimateControl.modify STATE_CHANGE_SLACK_URL: 'https://example.com/webhook' do
        invoke_worker
      end

      # Slack will begin the message with a < character (this codepoint) when presenting content as a link
      expect(slack_request.with(body: /\[TEST\] \\u003/)).to have_been_made
    end

    it 'does not include a link if none given' do
      slack_request = stub_request(:post, 'https://example.com/webhook')
        .to_return(status: 200, headers: {})

      ClimateControl.modify STATE_CHANGE_SLACK_URL: 'https://example.com/webhook' do
        described_class.new.perform('example text')
      end

      expect(slack_request.with(body: /\[TEST\] example text/)).to have_been_made
    end
  end

  def invoke_worker
    SlackNotificationWorker.new.perform('example text', 'https://example.com/support')
  end
end
