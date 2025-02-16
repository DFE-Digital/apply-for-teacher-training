require 'rails_helper'

RSpec.describe CycleTimetable do
  let(:this_year) { Time.zone.now.year }
  let(:next_year) { this_year + 1 }
  let(:last_year) { this_year - 1 }
  let(:next_next_year) { this_year + 2 }
  let(:one_hour_before_apply_deadline) { described_class.apply_deadline(this_year) - 1.hour }
  let(:one_hour_after_apply_deadline) { described_class.apply_deadline(this_year) + 1.hour  }
  let(:one_hour_after_this_year_cycle_opens) { described_class.apply_opens(this_year) + 1.hour }
  let(:one_hour_after_near_year_apply_opens) { described_class.apply_opens(next_year) + 1.hour }
  let(:one_hour_before_find_closes) { described_class.find_closes(this_year) - 1.hour }
  let(:one_hour_after_find_closes) { described_class.find_closes(this_year) + 1.hour }
  let(:one_hour_after_find_opens) { described_class.find_opens(this_year) + 1.hour }

  describe '.current_year' do
    it 'is this_year if we are in the middle of the this_year cycle' do
      travel_temporarily_to(one_hour_after_this_year_cycle_opens) do
        expect(described_class.current_year).to eq(this_year)
      end
    end

    it 'is next_year if we are in the middle of the next_year cycle' do
      travel_temporarily_to(one_hour_after_near_year_apply_opens) do
        expect(described_class.current_year).to eq(next_year)
      end
    end

    it 'returns this_year for the date of `apply_opens`' do
      travel_temporarily_to(described_class.apply_opens(this_year)) do
        expect(described_class.current_year).to eq(this_year)
      end
    end

    it 'returns last_year for current_year(CycleTimetable.find_opens(this_year))' do
      # What this test shows that right at the moment find_opens, #current_year returns the year before.
      # Like we haven't quite started the cycle yet.
      # This doesn't make sense to have the first date that defines a cycle not be included in the cycle.
      expect(described_class.current_year(described_class.find_opens(this_year))).to eq(last_year)
    end
  end

  describe '.next_year' do
    it 'is next_year if we are in the middle of the this_year cycle' do
      travel_temporarily_to(one_hour_after_this_year_cycle_opens) do
        expect(described_class.next_year).to eq(next_year)
      end
    end

    it 'is next_next_year if we are in the middle of the next_year cycle' do
      travel_temporarily_to(one_hour_after_near_year_apply_opens) do
        expect(described_class.next_year).to eq(next_next_year)
      end
    end
  end

  describe '.between_cycles?' do
    it 'returns false before if apply deadline has not passed' do
      travel_temporarily_to(one_hour_before_apply_deadline) do
        expect(described_class.between_cycles?).to be false
      end
    end

    it 'returns true after apply deadline has passed but find is still open' do
      travel_temporarily_to(one_hour_after_apply_deadline) do
        expect(described_class.between_cycles?).to be true
      end
    end

    it 'returns true between find and apply reopening' do
      travel_temporarily_to(one_hour_after_find_opens) do
        expect(described_class.between_cycles?).to be true
      end
    end

    it 'returns false after the new cycle opens' do
      travel_temporarily_to(one_hour_after_near_year_apply_opens) do
        expect(described_class.between_cycles?).to be false
      end
    end
  end

  describe '.find_down?' do
    it 'returns false before find closes' do
      travel_temporarily_to(one_hour_before_find_closes) do
        expect(described_class.find_down?).to be false
      end
    end

    it 'returns false after find_reopens' do
      travel_temporarily_to(one_hour_after_find_opens) do
        expect(described_class.find_down?).to be false
      end
    end

    it 'returns true between find_closes and find_reopens' do
      travel_temporarily_to(one_hour_after_find_closes) do
        expect(described_class.find_down?).to be true
      end
    end
  end

  describe '.next_apply_deadline' do
    context 'after cycle start and before apply deadline' do
      it 'returns apply_deadline' do
        travel_temporarily_to(one_hour_before_apply_deadline) do
          expect(described_class.next_apply_deadline).to eq(described_class.apply_deadline)
        end
      end
    end

    context 'after apply deadline' do
      it 'returns apply_deadline for next year' do
        travel_temporarily_to(one_hour_after_apply_deadline) do
          expect(described_class.next_apply_deadline).to eq(described_class.apply_deadline(next_year))
        end
      end
    end
  end

  describe '.cycle_year_range' do
    context 'with no year passed in' do
      it 'returns the `current_year to next_year`' do
        allow(described_class).to receive(:current_year).and_return(next_year)
        expect(described_class.cycle_year_range).to eq "#{next_year} to #{next_next_year}"
      end
    end

    context 'with a year passed in' do
      it 'returns `year to year + 1`' do
        expect(described_class.cycle_year_range(next_next_year)).to eq "#{next_next_year} to #{next_year + 2}"
      end
    end
  end

  describe '.between_reject_by_default_and_find_reopens?' do
    context 'it is before reject by default date' do
      it 'returns false' do
        travel_temporarily_to(described_class.reject_by_default - 1.day) do
          expect(described_class.between_reject_by_default_and_find_reopens?).to be(false)
        end
      end
    end

    context 'it is after reject by default date' do
      it 'returns true' do
        travel_temporarily_to(described_class.reject_by_default + 1.day) do
          expect(described_class.between_reject_by_default_and_find_reopens?).to be(true)
        end
      end
    end
  end

  describe '.before_apply_opens?' do
    context 'one second until apply_opens' do
      it 'opens at exactly the right time' do
        travel_temporarily_to(1.second.until(described_class.apply_opens)) do
          expect(described_class.before_apply_opens?).to be(true)
        end
      end
    end

    context 'one second after apply_opens' do
      it 'opens at exactly the right time' do
        travel_temporarily_to(1.second.after(described_class.apply_opens)) do
          expect(described_class.before_apply_opens?).to be(false)
        end
      end
    end
  end

  describe '.current_cycle_week' do
    # Sunday the week before find opens
    let(:date) { Time.zone.local(2023, 10, 1) }

    context 'the last week of the previous cycle' do
      it 'returns 52' do
        travel_temporarily_to(date) do
          expect(described_class.current_cycle_week).to be 52
        end
      end
    end

    context 'when Monday first week' do
      it 'returns 1' do
        travel_temporarily_to(date + 1.day) do
          expect(described_class.current_cycle_week).to be 1
        end
      end
    end

    context 'when Sunday first week' do
      it 'returns 1' do
        travel_temporarily_to(date + 7.days) do
          expect(described_class.current_cycle_week).to be 1
        end
      end
    end

    context 'when Monday second week' do
      it 'returns 2' do
        travel_temporarily_to(date + 8.days) do
          expect(described_class.current_cycle_week).to be 2
        end
      end
    end

    context 'when mid cycle' do
      it 'returns the week number' do
        travel_temporarily_to(date + 5.weeks) do
          expect(described_class.current_cycle_week).to be 5
        end
      end
    end

    context 'when last cycle week' do
      it 'returns 52' do
        travel_temporarily_to(date + 52.weeks) do
          expect(described_class.current_cycle_week).to be 52
        end
      end
    end

    context 'when the first week of the next cycle' do
      it 'returns 1' do
        travel_temporarily_to(date + 53.weeks) do
          expect(described_class.current_cycle_week).to be 1
        end
      end
    end

    context 'when the first week of the next cycle passed explicitly' do
      it 'returns 1' do
        expect(described_class.current_cycle_week(date + 53.weeks)).to be 1
      end
    end
  end
end
