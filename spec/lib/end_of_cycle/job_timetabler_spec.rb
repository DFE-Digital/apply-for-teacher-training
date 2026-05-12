require 'rails_helper'

RSpec.describe EndOfCycle::JobTimetabler do
  describe 'run_cancel_unsubmitted_applications?' do
    it 'does not run before apply deadline' do
      travel_temporarily_to(current_timetable.apply_deadline_at - 1.minute) do
        expect(described_class.new.run_cancel_unsubmitted_applications?).to be false
      end
    end

    it 'does not run after reject by default' do
      travel_temporarily_to(current_timetable.reject_by_default_at + 1.second) do
        expect(described_class.new.run_cancel_unsubmitted_applications?).to be false
      end
    end

    it 'runs between apply deadline and reject by default' do
      travel_temporarily_to(current_timetable.reject_by_default_at - 1.minute) do
        expect(described_class.new.run_cancel_unsubmitted_applications?).to be true
      end
    end
  end

  describe 'run_reject_by_default?' do
    it 'does not run before reject_by_default_at' do
      travel_temporarily_to(current_timetable.reject_by_default_at - 1.minute) do
        expect(described_class.new.run_reject_by_default?).to be false
      end
    end

    it 'does not run after decline by default at' do
      travel_temporarily_to(current_timetable.decline_by_default_at + 1.second) do
        expect(described_class.new.run_reject_by_default?).to be false
      end
    end

    it 'runs between reject by default and decline by default' do
      travel_temporarily_to(current_timetable.decline_by_default_at - 1.minute) do
        expect(described_class.new.run_reject_by_default?).to be true
      end
    end
  end

  describe 'run_decline_by_default?' do
    it 'does not run before decline by default' do
      travel_temporarily_to(current_timetable.decline_by_default_at - 1.minute) do
        expect(described_class.new.run_decline_by_default?).to be false
      end
    end

    it 'does not run after find closes' do
      travel_temporarily_to(current_timetable.find_closes_at + 1.second) do
        expect(described_class.new.run_decline_by_default?).to be false
      end
    end

    it 'runs between decline by default and find closes' do
      travel_temporarily_to(current_timetable.find_closes_at - 1.minute) do
        expect(described_class.new.run_decline_by_default?).to be true
      end
    end
  end

  describe '.run_winter_reject_by_default?' do
    subject(:run_winter_reject_by_default?) { instance.run_winter_reject_by_default? }

    let(:instance) { described_class.new }

    context 'when the timetable winter_reject_by_default_at attribute is nil' do
      it 'returns nil' do
        expect(instance.run_winter_reject_by_default?).to be_nil
      end
    end

    it 'does not run before winter reject by default' do
      allow(instance).to receive(:timetable).and_return(
        Struct.new(:winter_reject_by_default_at, :winter_decline_by_default_at).new(2.months.from_now, 3.months.from_now),
      )
      expect(instance.run_winter_reject_by_default?).to be(false)
    end

    it 'does not run after winter decline by default' do
      allow(instance).to receive(:timetable).and_return(
        Struct.new(:winter_reject_by_default_at, :winter_decline_by_default_at).new(2.months.ago, 1.month.ago),
      )
      expect(instance.run_winter_reject_by_default?).to be(false)
    end

    it 'runs between winter reject and decline by default' do
      allow(instance).to receive(:timetable).and_return(
        Struct.new(:winter_reject_by_default_at, :winter_decline_by_default_at).new(1.month.ago, 1.month.from_now),
      )
      expect(instance.run_winter_reject_by_default?).to be(true)
    end
  end

  describe '.run_winter_decline_by_default?' do
    subject(:run_winter_decline_by_default?) { instance.run_winter_decline_by_default? }

    let(:instance) { described_class.new }

    context 'when the timetable winter_decline_by_default_at attribute is nil' do
      it 'returns nil' do
        expect(instance.run_winter_decline_by_default?).to be_nil
      end
    end

    it 'does not run before winter decline by default' do
      allow(instance).to receive(:timetable).and_return(
        Struct.new(:winter_decline_by_default_at).new(2.months.from_now),
      )
      expect(instance.run_winter_decline_by_default?).to be(false)
    end

    it 'does not run after winter decline by default' do
      allow(instance).to receive(:timetable).and_return(
        Struct.new(:winter_decline_by_default_at).new(2.months.ago),
      )
      expect(instance.run_winter_decline_by_default?).to be(false)
    end

    it 'runs between winter decline by default and a month later' do
      allow(instance).to receive(:timetable).and_return(
        Struct.new(:winter_decline_by_default_at).new(1.month.ago),
      )
      expect(instance.run_winter_decline_by_default?).to be(true)
    end
  end
end
