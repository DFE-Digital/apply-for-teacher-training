module TestHelpers
  module LoggingHelper
    def environment_config_double
      lograge = Struct.new(:enabled, :base_controller_class, :custom_options, :formatter).new
      environment_config = Struct.new(:logger, :lograge).new
      allow(environment_config).to receive(:lograge).and_return(lograge)
      environment_config
    end

    def stub_rails_logger(logger)
      allow(Rails).to receive(:logger).and_return(logger)
    end

    def capture_stdout
      stringio_output = StringIO.new
      old_stdout = $stdout
      $stdout = stringio_output
      yield
      $stdout = old_stdout
      stringio_output.string
    end

    def capture_logstash_output(config)
      capture_stdout do
        ClimateControl.modify LOGSTASH_ENABLE: 'true' do
          LogstashLogging.enable(config)
          stub_rails_logger(config.logger)
        end
        yield
      end
    end
  end
end
