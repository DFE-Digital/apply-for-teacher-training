require 'clockwork/test'
require 'sidekiq'
require './app/workers/clockwork_check'

RSpec.describe Clockwork do
  after { Clockwork::Test.clear! }

  describe 'ClockworkCheck schedule' do
    it 'runs immediately after boot' do
      Clockwork::Test.run(max_ticks: 1, file: './config/clock.rb')
      expect(Clockwork::Test.ran_job?('ClockworkCheck')).to be_truthy
    end

    it 'runs the job every 5 minutes over the course of an hour' do
      timecop_safe_mode = Timecop.safe_mode?
      Timecop.safe_mode = false # cannot pass a timecop block to clockwork/test
      start_time = Time.new(2019, 11, 7, 2, 0, 0)
      end_time = Time.new(2019, 11, 7, 3, 0, 0)
      Clockwork::Test.run(
        start_time: start_time,
        end_time: end_time,
        tick_speed: 1.minute,
        file: './config/clock.rb',
      )
      expect(Clockwork::Test.times_run('ClockworkCheck')).to eq 12
      Timecop.safe_mode = timecop_safe_mode
    end

    it 'enqueues a background ClockworkCheck job' do
      allow(ClockworkCheck).to receive(:perform_async)
      Clockwork::Test.run(max_ticks: 1, file: './config/clock.rb')
      Clockwork::Test.block_for('ClockworkCheck').call
      expect(ClockworkCheck).to have_received(:perform_async).once
    end
  end
end
