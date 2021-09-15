require 'rails_helper'

RSpec.describe SupportInterface::StartOfCycleNotifier do
  describe '#call' do
    it 'does nothing when called on a day that is not the start of the cycle for the service' do
      Timecop.freeze(2021, 9, 7) do
        expect {
          described_class.new.call(service: :apply)
          described_class.new.call(service: :find)
        }.not_to change(StartOfCycleNotificationWorker.jobs, :size)
      end
    end

    it 'does nothing when called out of business hours for the service opening' do
      Timecop.freeze(2021, 10, 5, 8, 59) do
        expect {
          described_class.new.call(service: :find)
        }.not_to change(StartOfCycleNotificationWorker.jobs, :size)
      end

      Timecop.freeze(2021, 10, 5, 16, 2) do
        expect {
          described_class.new.call(service: :find)
        }.not_to change(StartOfCycleNotificationWorker.jobs, :size)
      end

      Timecop.freeze(2021, 10, 12, 8, 59) do
        expect {
          described_class.new.call(service: :apply)
        }.not_to change(StartOfCycleNotificationWorker.jobs, :size)
      end

      Timecop.freeze(2021, 10, 12, 16, 2) do
        expect {
          described_class.new.call(service: :apply)
        }.not_to change(StartOfCycleNotificationWorker.jobs, :size)
      end
    end

    it 'enqueues a StartOfCycleNotificationWorker job when called on the day Apply starts' do
      Timecop.freeze(2021, 10, 12, 9, 1) do
        expect {
          described_class.new.call(service: :apply)
        }.to change(StartOfCycleNotificationWorker.jobs, :size).by(1)
      end
    end

    it 'enqueues a StartOfCycleNotificationWorker job when called on the day Find starts' do
      Timecop.freeze(2021, 10, 5, 9, 1) do
        expect {
          described_class.new.call(service: :find)
        }.to change(StartOfCycleNotificationWorker.jobs, :size).by(1)
      end
    end
  end
end
