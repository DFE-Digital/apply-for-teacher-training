require 'rails_helper'
require 'clockwork/test'
require 'sidekiq'

RSpec.describe Clockwork, :clockwork do
  before do
    TestSuiteTimeMachine.travel_permanently_to(Time.zone.now.change(hour: 0, min: 0, sec: 0))
  end

  describe 'stats summary' do
    it 'only posts on weekdays' do
      start_time = Time.zone.now.beginning_of_week
      end_time = Time.zone.now.end_of_week
      Clockwork::Test.run(
        start_time:,
        end_time:,
        tick_speed: 1.hour,
      )

      expect(Clockwork::Test).to have_run('SendStatsSummaryToSlack').exactly(4).times
    end
  end

  [
    { worker: SendChaseEmailToCandidatesWorker, task: 'SendChaseEmailToCandidates' },
  ].each do |worker|
    describe 'worker schedule' do
      it 'runs the job every hour' do
        start_time = Time.zone.now
        end_time = 3.hours.from_now
        Clockwork::Test.run(
          start_time:,
          end_time:,
          tick_speed: 30.seconds,
          file: './config/clock.rb',
        )
        expect(Clockwork::Test.times_run(worker[:task])).to eq 3
      end

      it 'queues a worker task' do
        allow(worker[:worker]).to receive(:perform_async)
        Clockwork::Test.run(max_ticks: 60, tick_speed: 1.minute, file: './config/clock.rb')
        Clockwork::Test.block_for(worker[:task]).call
        expect(worker[:worker]).to have_received(:perform_async)
      end
    end
  end

  it 'executes all defined jobs without error' do
    start_time = Time.zone.now.beginning_of_day
    end_time = Time.zone.now.end_of_day

    Clockwork::Test.run(
      start_time:,
      end_time:,
      tick_speed: 1.minute,
      file: './config/clock.rb',
    )

    Clockwork::Test.manager.send(:history).jobs.each do |job|
      expect { Clockwork::Test.block_for(job).call }.not_to raise_error
    end
  end
end
