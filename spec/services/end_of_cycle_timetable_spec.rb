require 'rails_helper'

RSpec.describe EndOfCycleTimetable do
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

  describe '.show_apply_1_reopen_banner?' do
    it 'returns false before the configured date' do
      Timecop.travel(Time.zone.local(2020, 8, 24, 21, 0, 0)) do
        expect(EndOfCycleTimetable.show_apply_1_reopen_banner?).to be false
      end
    end

    it 'returns true after the configured date' do
      Timecop.travel(Time.zone.local(2020, 8, 25, 6, 0, 0)) do
        expect(EndOfCycleTimetable.show_apply_1_reopen_banner?).to be true
      end
    end

    it 'returns false after the new cycle opens' do
      Timecop.travel(Time.zone.local(2020, 10, 13, 12, 0, 0)) do
        expect(EndOfCycleTimetable.show_apply_1_reopen_banner?).to be false
      end
    end
  end

  describe '.show_apply_2_reopen_banner?' do
    it 'returns false before the configured date' do
      Timecop.travel(Time.zone.local(2020, 9, 18, 12, 0, 0)) do
        expect(EndOfCycleTimetable.show_apply_2_reopen_banner?).to be false
      end
    end

    it 'returns true after the configured date' do
      Timecop.travel(Time.zone.local(2020, 9, 19, 12, 0, 0)) do
        expect(EndOfCycleTimetable.show_apply_2_reopen_banner?).to be true
      end
    end

    it 'returns false after the new cycle opens' do
      Timecop.travel(Time.zone.local(2020, 10, 13, 12, 0, 0)) do
        expect(EndOfCycleTimetable.show_apply_2_reopen_banner?).to be false
      end
    end
  end
end
