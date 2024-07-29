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

  it 'adds custom fields to the log hash' do
    Thread.current[:job_id] = 'test_job_id'
    Thread.current[:job_queue] = 'test_queue'
    Thread.current['sidekiq_tid'] = 'test_tid'
    allow(Sidekiq::Context).to receive(:current).and_return('test_context')

    log.message = 'Started'
    log.payload = {
      method: 'GET',
      path: '/support/applications',
      ip: '::1',
      subject: 'Test Subject',
      to: 'test@example.com',
      params: { key: 'value' },
    }

    expect(log_hash[:domain]).to eq('test_host')
    expect(log_hash[:environment]).to eq('test_env')
    expect(log_hash[:hosting_environment]).to eq('test_env')
    expect(log_hash[:job_id]).to eq('test_job_id')
    expect(log_hash[:job_queue]).to eq('test_queue')
    expect(log_hash[:tid]).to eq('test_tid')
    expect(log_hash[:ctx]).to eq('test_context')
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
end
