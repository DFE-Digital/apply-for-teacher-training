require 'rails_helper'

RSpec.describe RecruitmentPerformanceReportTimetable do
  describe '#report_season?' do
    it 'returns false if before week 16' do
      travel_temporarily_to(current_timetable.cycle_week_date_range(15).first) do
        expect(described_class.report_season?).to be false
      end
    end

    it 'returns true after week 15' do
      travel_temporarily_to(current_timetable.cycle_week_date_range(16).first) do
        expect(described_class.report_season?).to be true
      end
    end
  end

  describe '#first_publication_date' do
    it 'returns the first Monday in the report season' do
      expected_date = current_timetable.cycle_week_date_range(16).first

      first_publication_date = described_class.first_publication_date
      expect(first_publication_date.monday?).to be true
      expect(first_publication_date).to eq expected_date
    end
  end

  describe 'current_generation_date and current_publication_date' do
    it 'generation and publication date are the same' do
      generation = described_class.current_generation_date
      publication = described_class.current_publication_date

      expect(generation.to_date).to eq publication.to_date
    end
  end
end
