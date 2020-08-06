require 'rails_helper'

RSpec.describe EndOfCycleTimetable do
  describe '.show_apply_1_deadline_banner?' do
    it 'returns true before the configured date' do
      Timecop.travel(Date.new(2020, 8, 23)) do
        expect(EndOfCycleTimetable.show_apply_1_deadline_banner?).to be true
      end
    end

    it 'returns false after the configured date' do
      Timecop.travel(Date.new(2020, 8, 24) + 1.hour) do
        expect(EndOfCycleTimetable.show_apply_1_deadline_banner?).to be false
      end
    end
  end

  describe '.show_apply_2_deadline_banner?' do
    it 'returns true before the configured date' do
      Timecop.travel(Date.new(2020, 9, 17)) do
        expect(EndOfCycleTimetable.show_apply_2_deadline_banner?).to be true
      end
    end

    it 'returns false after the configured date' do
      Timecop.travel(Date.new(2020, 9, 18) + 1.hour) do
        expect(EndOfCycleTimetable.show_apply_2_deadline_banner?).to be false
      end
    end
  end
end
