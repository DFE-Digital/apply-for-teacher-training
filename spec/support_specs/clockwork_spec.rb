require 'rails_helper'
require 'clockwork/test'
require 'sidekiq'
require './app/workers/clockwork_check'
require './app/workers/send_applications_to_provider_worker'
require './app/workers/decline_offers_by_default_worker'

RSpec.describe Clockwork do
  around do |example|
    Sidekiq::Testing.inline! do
      timecop_safe_mode = Timecop.safe_mode?
      Timecop.safe_mode = false # cannot pass a timecop block to clockwork/test
      example.run
      Timecop.safe_mode = timecop_safe_mode
    end
  end

  describe 'ClockworkCheck schedule' do
    it 'runs immediately after boot' do
      Clockwork::Test.run(max_ticks: 1, file: './config/clock.rb')
      expect(Clockwork::Test.ran_job?('ClockworkCheck')).to be_truthy
    end

    it 'runs the job every 5 minutes over the course of an hour' do
      start_time = Time.zone.local(2019, 11, 7, 2, 0, 0)
      end_time = Time.zone.local(2019, 11, 7, 3, 0, 0)
      Clockwork::Test.run(
        start_time: start_time,
        end_time: end_time,
        tick_speed: 1.minute,
        file: './config/clock.rb',
      )
      expect(Clockwork::Test.times_run('ClockworkCheck')).to eq 12
    end

    it 'enqueues a background ClockworkCheck job' do
      allow(ClockworkCheck).to receive(:perform_async)
      Clockwork::Test.run(max_ticks: 1, file: './config/clock.rb')
      Clockwork::Test.block_for('ClockworkCheck').call
      expect(ClockworkCheck).to have_received(:perform_async).once
    end
  end

  describe 'SendApplicationsToProviderWorker schedule' do
    before do
      @service = instance_double(SendApplicationsToProvider, call: true)
      allow(@service).to receive(:call).and_return(true)
      allow(SendApplicationsToProvider).to receive(:new).and_return(@service)
    end

    it 'runs the job every hour' do
      start_time = Time.zone.local(2019, 11, 7, 0, 4, 0)
      end_time = Time.zone.local(2019, 11, 7, 1, 6, 0)
      Clockwork::Test.run(
        start_time: start_time,
        end_time: end_time,
        tick_speed: 1.minute,
        file: './config/clock.rb',
      )
      expect(Clockwork::Test.times_run('SendApplicationsToProvider')).to eq 2
    end

    it 'queues a SendApplicationsToProvider worker' do
      start_time = Time.zone.local(2019, 11, 7, 0, 4, 0)
      end_time = Time.zone.local(2019, 11, 7, 1, 6, 0)
      Clockwork::Test.run(
        start_time: start_time,
        end_time: end_time,
        tick_speed: 1.minute,
        file: './config/clock.rb',
      )
      Clockwork::Test.block_for('SendApplicationsToProvider').call
      expect(@service).to have_received(:call)
    end
  end

  describe 'DeclineOffersByDefaultWorker schedule' do
    it 'runs the job every hour' do
      start_time = Time.zone.local(2019, 12, 2, 0, 0, 0)
      end_time = Time.zone.local(2019, 12, 2, 3, 0, 0)
      Clockwork::Test.run(
        start_time: start_time,
        end_time: end_time,
        tick_speed: 1.minute,
        file: './config/clock.rb',
      )
      expect(Clockwork::Test.times_run('DeclineOffersByDefault')).to eq 3
    end

    it 'queues a DeclineOffersByDefaultWorker task' do
      allow(DeclineOffersByDefaultWorker).to receive(:perform_async)
      Clockwork::Test.run(max_ticks: 60, tick_speed: 1.minute, file: './config/clock.rb')
      Clockwork::Test.block_for('DeclineOffersByDefault').call
      expect(DeclineOffersByDefaultWorker).to have_received(:perform_async)
    end
  end
end
