require 'rails_helper'

RSpec.describe EmailTimetable do
  describe '#send_first_end_of_cycle_reminder_to_candidates?' do
    it 'returns false if it is not the reminder date' do
      travel_temporarily_to(described_class.apply_deadline_first_reminder - 1.day) do
        expect(described_class.send_first_end_of_cycle_reminder_to_candidates?).to be false
      end
    end

    it 'returns true when it is the first apply deadline reminder date' do
      travel_temporarily_to(described_class.apply_deadline_first_reminder) do
        expect(described_class.send_first_end_of_cycle_reminder_to_candidates?).to be true
      end
    end
  end

  describe '#send_second_end_of_cycle_reminder_to_candidates?' do
    it 'returns false if it is not the reminder date' do
      travel_temporarily_to(described_class.apply_deadline_second_reminder - 1.day) do
        expect(described_class.send_second_end_of_cycle_reminder_to_candidates?).to be false
      end
    end

    it 'returns true when it is the second apply deadline reminder date' do
      travel_temporarily_to(described_class.apply_deadline_second_reminder) do
        expect(described_class.send_second_end_of_cycle_reminder_to_candidates?).to be true
      end
    end
  end

  describe '.send_find_has_opened_email?' do
    context 'it is before find reopens' do
      it 'returns false' do
        travel_temporarily_to(described_class.find_opens - 1.hour) do
          expect(described_class.send_find_has_opened_email?).to be(false)
        end
      end
    end

    context 'it is after find reopens' do
      it 'returns true' do
        travel_temporarily_to(described_class.find_opens + 1.hour) do
          expect(described_class.send_find_has_opened_email?).to be(true)
        end
      end
    end
  end

  describe '.send_new_cycle_has_started_email?' do
    context 'it is before apply reopens' do
      it 'returns false' do
        travel_temporarily_to(described_class.apply_reopens - 1.day) do
          expect(described_class.send_new_cycle_has_started_email?).to be(false)
        end
      end
    end

    context 'it is after apply reopens' do
      it 'returns true' do
        travel_temporarily_to(described_class.apply_opens) do
          expect(described_class.send_new_cycle_has_started_email?).to be(true)
        end
      end
    end
  end

  describe '#send_application_deadline_has_passed_email_to_candidates?' do
    it 'returns false if it is not the day after the apply deadline' do
      travel_temporarily_to(described_class.apply_deadline) do
        expect(described_class.send_application_deadline_has_passed_email_to_candidates?).to be false
      end
    end

    it 'returns true if it is the day after the apply deadline' do
      travel_temporarily_to(described_class.apply_deadline + 1.day) do
        expect(described_class.send_application_deadline_has_passed_email_to_candidates?).to be true
      end
    end
  end

  describe '#send_reject_by_default_explainer_to_candidates?' do
    it 'returns false if it is not the day after the reject by default date' do
      travel_temporarily_to(described_class.reject_by_default) do
        expect(described_class.send_reject_by_default_explainer_to_candidates?).to be false
      end
    end

    it 'returns true when it is the day after the reject by default date' do
      travel_temporarily_to(described_class.reject_by_default + 1.day) do
        expect(described_class.send_reject_by_default_explainer_to_candidates?).to be true
      end
    end
  end
end
