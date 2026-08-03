require 'rails_helper'

RSpec.describe CustomLogFormatter do
  subject(:log_hash) { JSON.parse(described_class.new.call(log, logger), symbolize_names: true) }

  let(:log) { SemanticLogger::Log.new('Rack', :debug) }
  let(:logger) do
    SemanticLogger::Appender::File.new(
      'test.log',
      retry_count: 1,
      append: true,
      reopen_period: nil,
      reopen_count: 0,
      reopen_size: 0,
      encoding: Encoding::BINARY,
      exclusive_lock: false,
    )
  end

  before do
    allow(HostingEnvironment).to receive_messages(hostname: 'test_host', environment_name: 'test_env')
  end

  it 'sanitizes the mailer subject and to fields' do
    log.message = 'Started'
    log.payload = {
      method: 'GET',
      path: '/support/applications',
      ip: '::1',
      subject: 'Test Subject',
      to: 'test@example.com',
      params: { key: 'value' },
    }

    expect(log_hash[:payload][:subject]).to eq('[REDACTED]')
    expect(log_hash[:payload][:to]).to eq('[REDACTED]')
  end

  it 'filters out email addresses after the successful delivery' do
    log.message = 'Delivered mail'
    log.payload = {
      event_name: 'deliver.action_mailer',
      mailer: 'CandidateMailer',
      action: nil,
      message_id: '1234@apply-review-1234-worker-1234-1234.mail',
      perform_deliveries: true,
      subject: '[REVIEW] You have submitted your teacher training application',
      to: ['some.email+testlog@education.gov.uk'],
      from: nil,
      bcc: nil,
      cc: nil,
      date: '2024-07-19 14:12:25 UTC',
      duration: 101.07,
      args: nil,
    }

    expect(log_hash[:payload][:subject]).to eq('[REDACTED]')
    expect(log_hash[:payload][:to]).to eq('[REDACTED]')
  end

  it 'filters out arguments when the job class is "ActionMailer::MailDeliveryJob"' do
    log.message = 'Enqueued Message'
    log.payload = {
      job_class: 'ActionMailer::MailDeliveryJob',
      arguments: {
        token: 'ABC123',
        email_address: 'email@email.example.com',
      },
      event_name: 'deliver.action_mailer',
      mailer: 'CandidateMailer',
      action: nil,
      message_id: '1234@apply-review-1234-worker-1234-1234.mail',
      perform_deliveries: true,
      subject: '[REVIEW] You have submitted your teacher training application',
      to: ['some.email+testlog@education.gov.uk'],
      from: nil,
      bcc: nil,
      cc: nil,
      date: '2024-07-19 14:12:25 UTC',
      duration: 101.07,
      args: nil,
    }

    expect(log_hash[:payload][:arguments]).to eq('[REDACTED]')
  end

  it 'filters out solid queue arguments' do
    log.message = 'Performed VendorAPIRequestWorker'
    log.payload = {
      job_class: 'VendorAPIRequestWorker',
      adapter: 'SolidQueue',
      arguments: 'PII',
    }
    expect(log_hash[:payload][:arguments]).to eq('[REDACTED]')
  end
end
