require 'rails_helper'

RSpec.describe SupportInterface::StartOfCycleNotifier do
  describe '#call' do
    let(:year) { RecruitmentCycle.current_year }

    it 'does nothing when called on a day that is not the start of the cycle for the service' do
      Timecop.freeze(6.months.before(CycleTimetable.find_opens(year))) do
        expect {
          described_class.new.call(service: :apply, year: year)
          described_class.new.call(service: :find, year: year)
        }.not_to change(StartOfCycleNotificationWorker.jobs, :size)
      end
    end

    it 'does nothing when called out of business hours for the service opening' do
      Timecop.freeze(CycleTimetable.find_opens(year).change(hour: 8, min: 59)) do
        expect {
          described_class.new.call(service: :find, year: year)
        }.not_to change(StartOfCycleNotificationWorker.jobs, :size)
      end

      Timecop.freeze(CycleTimetable.find_opens(year).change(hour: 16, min: 2)) do
        expect {
          described_class.new.call(service: :find, year: year)
        }.not_to change(StartOfCycleNotificationWorker.jobs, :size)
      end

      Timecop.freeze(CycleTimetable.apply_opens(year).change(hour: 8, min: 59)) do
        expect {
          described_class.new.call(service: :apply, year: year)
        }.not_to change(StartOfCycleNotificationWorker.jobs, :size)
      end

      Timecop.freeze(CycleTimetable.apply_opens(year).change(hour: 16, min: 2)) do
        expect {
          described_class.new.call(service: :apply, year: year)
        }.not_to change(StartOfCycleNotificationWorker.jobs, :size)
      end
    end

    it 'enqueues a StartOfCycleNotificationWorker job when called on the day Apply starts' do
      Timecop.freeze(1.minute.since(CycleTimetable.apply_opens(year))) do
        expect {
          described_class.new.call(service: :apply, year: year)
        }.to change(StartOfCycleNotificationWorker.jobs, :size).by(1)
      end
    end

    it 'enqueues a StartOfCycleNotificationWorker job when called on the day Find starts' do
      Timecop.freeze(1.minute.since(CycleTimetable.find_opens(year))) do
        expect {
          described_class.new.call(service: :find, year: year)
        }.to change(StartOfCycleNotificationWorker.jobs, :size).by(1)
      end
    end
  end
end
