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
end
