require 'rails_helper'
require 'clockwork/test'
require 'sidekiq'

RSpec.describe Clockwork do
  around do |example|
    Sidekiq::Testing.inline! do
      timecop_safe_mode = Timecop.safe_mode?
      Timecop.safe_mode = false # cannot pass a timecop block to clockwork/test
      example.run
      Timecop.safe_mode = timecop_safe_mode
    end
  end

  [
    { worker: DeclineOffersByDefaultWorker, task: 'DeclineOffersByDefault' },
    { worker: SendChaseEmailToProvidersWorker, task: 'SendChaseEmailToProviders' },
    { worker: SendChaseEmailToCandidatesWorker, task: 'SendChaseEmailToCandidates' },
  ].each do |worker|
    describe 'worker schedule', clockwork: true do
      it 'runs the job every hour' do
        start_time = Time.zone.local(2020, 1, 2, 0, 0, 0)
        end_time = Time.zone.local(2020, 1, 2, 3, 0, 0)
        Clockwork::Test.run(
          start_time: start_time,
          end_time: end_time,
          tick_speed: 1.minute,
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
end
