require 'rails_helper'

RSpec.describe ClockworkCheck do
  include TestHelpers::LoggingHelper
  let(:rails_config) { environment_config_double }

  describe 'ClockworkCheck' do
    let(:output) { capture_logstash_output(rails_config) { ClockworkCheck.new.perform } }

    it 'logs it has run to the default Rails logger' do
      expect(output).not_to be_blank
    end

    it 'says "clockwork is running..."' do
      expect(output).to match(/clockwork is running\.\.\./)
    end
  end
end
