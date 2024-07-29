require 'rails_helper'

RSpec.describe FilteredMailPayload do
  let(:formatter_klass) do
    Class.new do
      def initialize(event)
        @event = event
      end

    private

      def mailer
        'UserMailer'
      end

      def action
        'welcome_email'
      end

      def date
        Time.zone.now
      end

      def log_duration?
        true
      end
    end
  end
  let(:formatter) { formatter_klass.new(event) }
  let(:event) do
    instance_double(
      ActiveSupport::Notifications::Event,
      name: 'process_action.action_mailer',
      payload: payload,
      duration: 2.345,
    )
  end

  let(:payload) do
    {
      mailer: 'UserMailer',
      action: 'welcome_email',
      message_id: '12345',
      perform_deliveries: true,
      subject: 'Welcome!',
      to: 'user@example.com',
      from: 'noreply@example.com',
      bcc: 'bcc@example.com',
      cc: 'cc@example.com',
      date: Time.zone.now,
      args: %w[arg1 arg2],
    }
  end
  let(:stubbed_filtered_parameters) do
    %w[
      mailer.subject
      mailer.to
      mailer.from
      mailer.bcc
      mailer.cc
      mailer.args
    ]
  end

  before do
    allow(Rails.application.config).to receive(:filter_parameters).and_return(stubbed_filtered_parameters)
    allow(formatter).to receive_messages(
      mailer: 'UserMailer',
      action: 'welcome_email',
      date: Time.zone.now,
      log_duration?: true,
    )
  end

  describe '#filtered_payload' do
    subject(:filtered_payload) { described_class.new(formatter, event).filtered_payload }

    it 'filters the subject' do
      expect(filtered_payload[:subject]).to eq('[FILTERED]')
    end

    it 'filters the to' do
      expect(filtered_payload[:to]).to eq('[FILTERED]')
    end

    it 'filters the from' do
      expect(filtered_payload[:from]).to eq('[FILTERED]')
    end

    it 'filters the bcc' do
      expect(filtered_payload[:bcc]).to eq('[FILTERED]')
    end

    it 'filters the cc' do
      expect(filtered_payload[:cc]).to eq('[FILTERED]')
    end

    it 'filters the args' do
      expect(filtered_payload[:args]).to eq('[FILTERED]')
    end

    it 'does not filter other attributes' do
      expect(filtered_payload[:event_name]).to eq('process_action.action_mailer')
      expect(filtered_payload[:mailer]).to eq('UserMailer')
      expect(filtered_payload[:action]).to eq('welcome_email')
      expect(filtered_payload[:message_id]).to eq('12345')
      expect(filtered_payload[:perform_deliveries]).to be(true)
      expect(filtered_payload[:date]).to be_a(Time)
      expect(filtered_payload[:duration]).to eq(2.35)
    end
  end
end
