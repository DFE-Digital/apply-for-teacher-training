require 'rails_helper'

RSpec.describe EndOfCycleTimetable do
  context 'when `simulate_time_between_cycles` feature flag is NOT active' do
    describe '.show_apply_1_deadline_banner?' do
      it 'returns true before the configured date' do
        Timecop.travel(Time.zone.local(2020, 8, 24, 23, 0, 0)) do
          expect(EndOfCycleTimetable.show_apply_1_deadline_banner?).to be true
        end
      end

      it 'returns false after the configured date' do
        Timecop.travel(Time.zone.local(2020, 8, 25, 1, 0, 0)) do
          expect(EndOfCycleTimetable.show_apply_1_deadline_banner?).to be false
        end
      end
    end

    describe '.show_apply_2_deadline_banner?' do
      it 'returns true before the configured date' do
        Timecop.travel(Time.zone.local(2020, 9, 18, 23, 0, 0)) do
          expect(EndOfCycleTimetable.show_apply_2_deadline_banner?).to be true
        end
      end

      it 'returns false after the configured date' do
        Timecop.travel(Time.zone.local(2020, 9, 19, 1, 0, 0)) do
          expect(EndOfCycleTimetable.show_apply_2_deadline_banner?).to be false
        end
      end
    end

    describe '.between_cycles_apply_1?' do
      it 'returns false before the configured date' do
        Timecop.travel(Time.zone.local(2020, 8, 24, 21, 0, 0)) do
          expect(EndOfCycleTimetable.between_cycles_apply_1?).to be false
        end
      end

      it 'returns true after the configured date' do
        Timecop.travel(Time.zone.local(2020, 8, 25, 6, 0, 0)) do
          expect(EndOfCycleTimetable.between_cycles_apply_1?).to be true
        end
      end

      it 'returns false after the new cycle opens' do
        Timecop.travel(Time.zone.local(2020, 10, 13, 12, 0, 0)) do
          expect(EndOfCycleTimetable.between_cycles_apply_1?).to be false
        end
      end
    end

    describe '.between_cycles_apply_2?' do
      it 'returns false before the configured date' do
        Timecop.travel(Time.zone.local(2020, 9, 18, 12, 0, 0)) do
          expect(EndOfCycleTimetable.between_cycles_apply_2?).to be false
        end
      end

      it 'returns true after the configured date' do
        Timecop.travel(Time.zone.local(2020, 9, 19, 12, 0, 0)) do
          expect(EndOfCycleTimetable.between_cycles_apply_2?).to be true
        end
      end

      it 'returns false after the new cycle opens' do
        Timecop.travel(Time.zone.local(2020, 10, 13, 12, 0, 0)) do
          expect(EndOfCycleTimetable.between_cycles_apply_2?).to be false
        end
      end
    end
  end

  context 'when `simulate_time_between_cycles` feature flag is active' do
    before { FeatureFlag.activate(:simulate_time_between_cycles) }

    describe '.show_apply_1_deadline_banner?' do
      it 'returns true before the configured date' do
        Timecop.travel(Time.zone.local(2020, 8, 24, 23, 0, 0)) do
          expect(EndOfCycleTimetable.show_apply_1_deadline_banner?).to be false
        end
      end

      it 'returns false after the configured date' do
        Timecop.travel(Time.zone.local(2020, 8, 25, 1, 0, 0)) do
          expect(EndOfCycleTimetable.show_apply_1_deadline_banner?).to be false
        end
      end
    end

    describe '.show_apply_2_deadline_banner?' do
      it 'returns true before the configured date' do
        Timecop.travel(Time.zone.local(2020, 9, 18, 23, 0, 0)) do
          expect(EndOfCycleTimetable.show_apply_2_deadline_banner?).to be false
        end
      end

      it 'returns false after the configured date' do
        Timecop.travel(Time.zone.local(2020, 9, 19, 1, 0, 0)) do
          expect(EndOfCycleTimetable.show_apply_2_deadline_banner?).to be false
        end
      end
    end

    describe '.between_cycles_apply_1?' do
      it 'returns false before the configured date' do
        Timecop.travel(Time.zone.local(2020, 8, 24, 21, 0, 0)) do
          expect(EndOfCycleTimetable.between_cycles_apply_1?).to be true
        end
      end

      it 'returns true after the configured date' do
        Timecop.travel(Time.zone.local(2020, 8, 25, 6, 0, 0)) do
          expect(EndOfCycleTimetable.between_cycles_apply_1?).to be true
        end
      end

      it 'returns false after the new cycle opens' do
        Timecop.travel(Time.zone.local(2020, 10, 13, 12, 0, 0)) do
          expect(EndOfCycleTimetable.between_cycles_apply_1?).to be true
        end
      end
    end

    describe '.between_cycles_apply_2?' do
      it 'returns false before the configured date' do
        Timecop.travel(Time.zone.local(2020, 9, 18, 12, 0, 0)) do
          expect(EndOfCycleTimetable.between_cycles_apply_2?).to be true
        end
      end

      it 'returns true after the configured date' do
        Timecop.travel(Time.zone.local(2020, 9, 19, 12, 0, 0)) do
          expect(EndOfCycleTimetable.between_cycles_apply_2?).to be true
        end
      end

      it 'returns false after the new cycle opens' do
        Timecop.travel(Time.zone.local(2020, 10, 13, 12, 0, 0)) do
          expect(EndOfCycleTimetable.between_cycles_apply_2?).to be true
        end
      end
    end
  end

  describe '.next_cycle_year' do
    it 'returns 2021 when in 2020 cycle' do
      Timecop.travel(Time.zone.local(2020, 8, 24, 23, 0, 0)) do
        expect(EndOfCycleTimetable.next_cycle_year).to eq 2021
      end
    end
  end
end
