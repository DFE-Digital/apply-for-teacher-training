require 'rails_helper'

RSpec.describe LogstashLogging do
  include TestHelpers::CaptureStdoutHelper

  before {
    @lograge = Struct.new(:enabled, :base_controller_class, :custom_options, :formatter).new
    @rails_config = Struct.new(:logger, :lograge).new
    allow(@rails_config).to receive(:lograge).and_return(@lograge)
  }

  describe 'can modify a Rails config object and' do
    before {
      ClimateControl.modify LOGSTASH_ENABLE: 'true' do
        LogstashLogging.enable(@rails_config)
      end
      @logger = @rails_config.logger
    }

    it 'makes the default logger a LogStashLogger' do
      expect(@logger).to be_kind_of(LogStashLogger)
    end
  end

  describe 'logs to STDOUT' do
    before {
      ClimateControl.modify LOGSTASH_ENABLE: 'true' do
        LogstashLogging.enable(@rails_config)
      end
      @logger = @rails_config.logger
      @logger.info 'test'
      @log = JSON.parse(@stdout_output.string) rescue nil
    }

    it 'producing valid JSON' do
      expect { JSON.parse @stdout_output.string }.not_to raise_error
    end

    it 'including the message' do
      expect(@log['message']).to eq 'test'
    end

    it 'including a @timestamp' do
      expect { DateTime.parse @log['@timestamp'] }.not_to raise_error
    end

    it 'including the domain' do
      expect(@log['domain']).to eq Socket.gethostname
    end

    it 'including the service name' do
      expect(@log['service']).to eq 'test' # ENV['SERVICE_NAME'] is set in spec_helper.rb
    end
  end

  describe 'contexts' do
    context 'web' do
      before {
        ClimateControl.modify LOGSTASH_ENABLE: 'true' do
          LogstashLogging.enable(@rails_config)
        end
        @logger = @rails_config.logger
        RequestLocals.store[:identity] = { candidate_id: 15 }
        @logger.info 'test'
        @log = JSON.parse(@stdout_output.string) rescue nil
      }

      it 'adds candidate_id to the log if it is defined' do
        expect(@log['candidate_id']).to eq 15
      end
    end

    context 'sidekiq' do
      before {
        ClimateControl.modify LOGSTASH_ENABLE: 'true' do
          LogstashLogging.enable(@rails_config)
        end
        @logger = @rails_config.logger
        Thread.current['sidekiq_tid'] = 'gnar6jfq9'
        @ctx = { 'class' => 'ClockworkCheck', 'jid' => 'de35b052045557e5b26b4659' }
        allow(Sidekiq::Context).to receive(:current).and_return(@ctx)
        @logger.info 'test'
        @log = JSON.parse(@stdout_output.string) rescue nil
      }

      it 'adds tid to the log if it is available' do
        expect(@log['tid']).to eq 'gnar6jfq9'
      end

      it 'adds ctx to the log if it is available' do
        expect(@log['ctx']).to eq @ctx
      end
    end
  end
end
