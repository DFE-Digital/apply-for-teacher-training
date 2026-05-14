require 'rails_helper'

RSpec.describe EndOfCycle::WinterJobTimetabler do
  let(:instance) { described_class.new }

  describe '.run_winter_reject_by_default?' do
    subject(:run_winter_reject_by_default?) { instance.run_winter_reject_by_default? }

    context 'when the timetable winter_reject_by_default_at attribute is nil' do
      it 'returns false' do
        expect(instance.run_winter_reject_by_default?).to be(false)
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

    context 'when the timetable winter_decline_by_default_at attribute is nil' do
      it 'returns false' do
        expect(instance.run_winter_decline_by_default?).to be(false)
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
