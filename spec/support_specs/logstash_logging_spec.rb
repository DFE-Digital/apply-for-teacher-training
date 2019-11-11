require 'rails_helper'

RSpec.describe LogstashLogging do
  include TestHelpers::LoggingHelper
  let(:rails_config) { environment_config_double }

  describe 'can modify a Rails config object and' do
    it 'makes the default logger a LogStashLogger' do
      ClimateControl.modify LOGSTASH_ENABLE: 'true' do
        LogstashLogging.enable(rails_config)
      end

      expect(rails_config.logger).to be_kind_of(LogStashLogger)
    end
  end

  describe 'logs to STDOUT' do
    let(:logger) { rails_config.logger }
    let(:output) { capture_logstash_output(rails_config) { rails_config.logger.info 'test' } }
    let(:log)    { JSON.parse(output) rescue nil }

    it 'producing valid JSON' do
      expect { JSON.parse output }.not_to raise_error
    end

    it 'including the message' do
      expect(log['message']).to eq 'test'
    end

    it 'including a @timestamp' do
      expect { DateTime.parse log['@timestamp'] }.not_to raise_error
    end

    it 'including the domain' do
      expect(log['domain']).to eq Socket.gethostname
    end

    it 'including the service name' do
      expect(log['service']).to eq 'test' # ENV['SERVICE_TYPE'] is set in spec_helper.rb
    end
  end

  describe 'contexts' do
    let(:logger) { rails_config.logger }
    let(:output) { capture_logstash_output(rails_config) { rails_config.logger.info 'test' } }
    let(:log)    { JSON.parse(output) rescue nil }

    context 'web' do
      it 'adds candidate_id to the log if it is defined' do
        RequestLocals.store[:identity] = { candidate_id: 15 }
        expect(log['candidate_id']).to eq 15
      end
    end

    context 'sidekiq' do
      let(:ctx) { { 'class' => 'ClockworkCheck', 'jid' => 'de35b052045557e5b26b4659' } }

      before do
        Thread.current['sidekiq_tid'] = 'gnar6jfq9'
        allow(Sidekiq::Context).to receive(:current).and_return(ctx)
      end

      it 'adds tid to the log if it is available' do
        expect(log['tid']).to eq 'gnar6jfq9'
      end

      it 'adds ctx to the log if it is available' do
        expect(log['ctx']).to eq ctx
      end
    end
  end
end
