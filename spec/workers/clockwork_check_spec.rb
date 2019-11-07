require 'rails_helper'

RSpec.describe ClockworkCheck do
  before {
    @stringio_output = StringIO.new
    @stringio_logger = Logger.new(@stringio_output)
    allow(Rails).to receive(:logger).and_return(@stringio_logger)
  }

  describe 'ClockworkCheck' do
    before { ClockworkCheck.new.perform }

    it 'logs it has run to the default Rails logger' do
      expect(@stringio_output.string).not_to be_blank
    end

    it 'says "clockwork is running..."' do
      expect(@stringio_output.string).to match(/clockwork is running\.\.\./)
    end
  end
end
