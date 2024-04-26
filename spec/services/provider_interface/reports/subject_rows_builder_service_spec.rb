require 'rails_helper'

FIELD_MAPPING_WITH_CHANGE = {
  this_cycle: 'number_of_candidates_submitted_to_date',
  last_cycle: 'number_of_candidates_submitted_to_same_date_previous_cycle',
  percentage_change: 'number_of_candidates_submitted_to_date_as_proportion_of_last_cycle',
}.freeze

FIELD_MAPPING_WITHOUT_CHANGE = {
  this_cycle: 'number_of_candidates_submitted_to_date',
  last_cycle: 'number_of_candidates_submitted_to_same_date_previous_cycle',
}.freeze

FIELD_MAPPING_THIS_CYCLE_ONLY = {
  this_cycle: 'number_of_candidates_submitted_to_date',
}.freeze

RSpec.describe ProviderInterface::Reports::SubjectRowsBuilderService do
  describe '#summary row' do
    it 'returns only the summary data row' do
      provider_statistics = create(:provider_recruitment_performance_report).statistics
      national_statistics = create(:national_recruitment_performance_report).statistics

      summary_row = described_class.new(
        field_mapping: FIELD_MAPPING_WITH_CHANGE,
        provider_statistics:,
        national_statistics:,
      ).summary_row
      expect(summary_row.title).to eq 'All'
      expect(summary_row.level).to eq 'All'
    end
  end

  describe '#subject_rows' do
    describe 'a field mapping with change data' do
      it 'includes change data' do
        provider_statistics = create(:provider_recruitment_performance_report).statistics
        national_statistics = create(:national_recruitment_performance_report).statistics

        rows = described_class.new(
          field_mapping: FIELD_MAPPING_WITH_CHANGE,
          provider_statistics:,
          national_statistics:,
        ).subject_rows

        rows_with_percentage_change = rows.find_all do |row|
          row.percentage_change.present? || row.national_percentage_change.present?
        end

        expect(rows_with_percentage_change.empty?).to be false
      end
    end

    describe 'a field mapping that does not including percentage change data' do
      it 'does not include percentage change data for each row' do
        provider_statistics = create(:provider_recruitment_performance_report).statistics
        national_statistics = create(:national_recruitment_performance_report).statistics

        rows = described_class.new(
          field_mapping: FIELD_MAPPING_WITHOUT_CHANGE,
          provider_statistics:,
          national_statistics:,
        ).subject_rows

        rows_with_percentage_change = rows.find_all do |row|
          row.percentage_change.present? || row.national_percentage_change.present?
        end

        expect(rows_with_percentage_change.empty?).to be true
      end
    end

    describe 'a field mapping only include this cycle' do
      it 'only includes this cycle only data' do
        provider_statistics = create(:provider_recruitment_performance_report).statistics
        national_statistics = create(:national_recruitment_performance_report).statistics

        rows = described_class.new(
          field_mapping: FIELD_MAPPING_THIS_CYCLE_ONLY,
          provider_statistics:,
          national_statistics:,
        ).subject_rows

        rows_with_percentage_change = rows.find_all do |row|
          row.percentage_change.present? || row.national_percentage_change.present?
        end

        rows_with_last_cycle_data = rows.find_all do |row|
          row.last_cycle.present? || row.national_last_cycle.present?
        end

        expect(rows_with_percentage_change.empty?).to be true
        expect(rows_with_last_cycle_data.empty?).to be true
      end
    end

    describe 'provider has primary only data' do
      it 'returns only primary rows' do
        provider_statistics = create(:provider_recruitment_performance_report, :primary_only).statistics
        national_statistics = create(:national_recruitment_performance_report).statistics

        rows = described_class.new(
          field_mapping: FIELD_MAPPING_WITHOUT_CHANGE,
          provider_statistics:,
          national_statistics:,
        ).subject_rows

        subjects = rows.map(&:title)
        expect(subjects).to contain_exactly('Primary')
      end
    end

    describe 'provider has only secondary data' do
      it 'returns only secondary rows' do
        provider_statistics = create(:provider_recruitment_performance_report, :secondary_only).statistics
        national_statistics = create(:national_recruitment_performance_report).statistics

        rows = described_class.new(
          field_mapping: FIELD_MAPPING_WITHOUT_CHANGE,
          provider_statistics:,
          national_statistics:,
        ).subject_rows

        subjects = rows.map(&:title)
        expect(subjects).to contain_exactly('Secondary', 'Art & Design', 'Biology', 'Chemistry', 'Computing',
                                            'Design & Technology', 'Drama', 'English', 'Geography', 'History',
                                            'Mathematics', 'Modern Foreign Languages', 'Music', 'Others',
                                            'Physical Education', 'Physics', 'Religious Education')
      end
    end

    it 'returns rows ordered by level and then title' do
      provider_statistics = create(:provider_recruitment_performance_report).statistics
      national_statistics = create(:national_recruitment_performance_report).statistics
      rows = described_class.new(
        field_mapping: FIELD_MAPPING_WITHOUT_CHANGE,
        provider_statistics:,
        national_statistics:,
      ).subject_rows

      titles = rows.map { |row| [row.level, row.title] }
      expect(titles).to eq [
        # Combined primary data
        %w[Level Primary],

        # Combined secondary data
        %w[Level Secondary],

        # Individual secondary subjects
        ['Secondary subject', 'Art & Design'],
        ['Secondary subject', 'Biology'],
        ['Secondary subject', 'Chemistry'],
        ['Secondary subject', 'Computing'],
        ['Secondary subject', 'Design & Technology'],
        ['Secondary subject', 'Drama'],
        ['Secondary subject', 'English'],
        ['Secondary subject', 'Geography'],
        ['Secondary subject', 'History'],
        ['Secondary subject', 'Mathematics'],
        ['Secondary subject', 'Modern Foreign Languages'],
        ['Secondary subject', 'Music'],
        ['Secondary subject', 'Others'],
        ['Secondary subject', 'Physical Education'],
        ['Secondary subject', 'Physics'],
        ['Secondary subject', 'Religious Education'],
      ]
    end
  end
end
