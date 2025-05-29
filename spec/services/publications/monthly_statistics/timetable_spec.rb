require 'rails_helper'

RSpec.describe Publications::MonthlyStatistics::Timetable do
  describe '#schedules' do
    subject(:schedules) { described_class.new.schedules }

    it 'all generation dates are before find closes' do
      generation_dates_after_find_closes = schedules.filter do |schedule|
        schedule.generation_date.after? current_timetable.find_closes_at
      end
      expect(generation_dates_after_find_closes).to eq []
    end

    it 'all generation dates are at least 4 weeks after apply opens' do
      generation_dates_before_4_weeks_after_apply_opens = schedules.filter do |schedule|
        schedule.generation_date.before? current_timetable.apply_opens_at + 4.weeks
      end

      expect(generation_dates_before_4_weeks_after_apply_opens).to eq []
    end

    it 'publication dates are all 1 week after generation dates' do
      schedules.each do |schedule|
        expect(schedule.publication_date).to eq(schedule.generation_date + 1.week)
      end
    end

    it 'all generation dates are the third Monday of the month' do
      schedules.each do |schedule|
        # It's a Monday
        expect(schedule.generation_date.monday?).to be true
        # If it's the third Monday, the Monday two weeks ago will be in the same month
        expect(schedule.generation_date.month).to eq((schedule.generation_date - 2.weeks).month)
        # And the Monday three weeks ago will be in the previous month
        expect(schedule.generation_date.month).not_to eq((schedule.generation_date - 3.weeks).month)
      end
    end
  end

  describe '#unpublished_schedules' do
    subject(:unpublished_schedules) { described_class.new.unpublished_schedules }

    let(:all_schedules) { described_class.new.schedules }

    it 'returns only those schedules where the publication date is in the future' do
      second_schedule = all_schedules.second
      travel_temporarily_to(second_schedule.generation_date + 1.day) do
        # The generation date of the second schedule has passed, but not the publication date.
        # so the second schedule is included in the result
        # The only one excluded is the first schedule
        expect(unpublished_schedules.count).to eq all_schedules.count - 1
        expect(unpublished_schedules.first.generation_date).to eq(all_schedules.second.generation_date)
      end
    end
  end

  describe '#next_publication_date' do
    subject(:next_publication_date) { described_class.new.next_publication_date }

    let(:all_schedules) { described_class.new.schedules }
    let(:next_cycle_schedules) { described_class.new(recruitment_cycle_timetable: next_timetable).schedules }

    it 'returns the first publication date of the next cycle if after the last publication date' do
      travel_temporarily_to(all_schedules.last.publication_date + 1.day) do
        expect(next_publication_date).to eq next_cycle_schedules.first.publication_date
      end
    end
  end

  describe '#generate_today?' do
    subject(:generate_today?) { described_class.new.generate_today? }

    let(:generation_date) { described_class.new.schedules.map(&:generation_date).sample }

    it 'returns true if today is a day schedule to generate statistics' do
      travel_temporarily_to(generation_date) do
        expect(generate_today?).to be true
      end
    end

    it 'returns false if it is not' do
      travel_temporarily_to(generation_date + 1.day) do
        expect(generate_today?).to be false
      end
    end
  end

  describe 'generated_schedules' do
    subject(:generated_schedules) { described_class.new.generated_schedules }

    let(:first_generation_date) { described_class.new.schedules.first.generation_date }

    it 'returns no schedules if the first generation date is not in the past' do
      travel_temporarily_to(first_generation_date) do
        expect(generated_schedules.count).to eq 0
      end
    end

    it 'returns schedules where the generation date is in the past' do
      travel_temporarily_to(first_generation_date + 1.day) do
        expect(generated_schedules.count).to eq 1
      end
    end
  end
end
