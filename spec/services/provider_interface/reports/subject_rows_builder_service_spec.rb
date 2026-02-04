require 'rails_helper'

RSpec.describe ProviderInterface::Reports::SubjectRowsBuilderService do
  let(:field_mapping_with_change) do
    {
      this_cycle: 'number_of_candidates_submitted_to_date',
      last_cycle: 'number_of_candidates_submitted_to_same_date_previous_cycle',
      percentage_change: 'number_of_candidates_submitted_to_date_as_proportion_of_last_cycle',
    }
  end

  let(:field_mapping_without_change) do
    {
      this_cycle: 'number_of_candidates_submitted_to_date',
      last_cycle: 'number_of_candidates_submitted_to_same_date_previous_cycle',
    }
  end

  let(:field_mapping_this_cycle_only) do
    { this_cycle: 'number_of_candidates_submitted_to_date' }
  end
  let(:report_type) { :NATIONAL }

  describe '#summary row' do
    it 'returns only the summary data row' do
      provider_statistics = create(:provider_recruitment_performance_report).statistics
      statistics = create(:national_recruitment_performance_report).statistics

      summary_row = described_class.new(
        field_mapping: field_mapping_with_change,
        provider_statistics:,
        statistics:,
        type: report_type,
      ).summary_row
      expect(summary_row.title).to eq 'All'
      expect(summary_row.level).to eq 'All'
    end

    context 'regional report type' do
      let(:report_type) { :REGIONAL }

      it 'returns only the summary data row' do
        provider_statistics = create(:provider_recruitment_performance_report).statistics
        regional_statistics = create(:regional_recruitment_performance_report).statistics

        summary_row = described_class.new(
          field_mapping: field_mapping_with_change,
          provider_statistics:,
          statistics: regional_statistics,
          type: report_type,
        ).summary_row
        expect(summary_row).to be_present
        expect(summary_row).to be_present
      end
    end
  end

  describe '#subject_rows' do
    describe 'a field mapping with change data' do
      it 'includes change data' do
        provider_statistics = create(:provider_recruitment_performance_report).statistics
        statistics = create(:national_recruitment_performance_report).statistics

        rows = described_class.new(
          field_mapping: field_mapping_with_change,
          provider_statistics:,
          statistics:,
          type: report_type,
        ).subject_rows

        rows_with_percentage_change = rows.find_all do |row|
          row.percentage_change.present? || row.national_percentage_change.present?
        end

        expect(rows_with_percentage_change.empty?).to be false
      end

      context 'regional report type' do
        let(:report_type) { :REGIONAL }

        it 'returns only the summary data row' do
          provider_statistics = create(:provider_recruitment_performance_report).statistics
          regional_statistics = create(:regional_recruitment_performance_report).statistics

          rows = described_class.new(
            field_mapping: field_mapping_with_change,
            provider_statistics:,
            statistics: regional_statistics,
            type: report_type,
          ).subject_rows

          rows_with_percentage_change = rows.find_all do |row|
            row.percentage_change.present? || row.national_percentage_change.present?
          end

          expect(rows_with_percentage_change.empty?).to be false
        end
      end
    end

    describe 'a field mapping that does not including percentage change data' do
      it 'does not include percentage change data for each row' do
        provider_statistics = create(:provider_recruitment_performance_report).statistics
        statistics = create(:national_recruitment_performance_report).statistics

        rows = described_class.new(
          field_mapping: field_mapping_without_change,
          provider_statistics:,
          statistics:,
          type: report_type,
        ).subject_rows

        rows_with_percentage_change = rows.find_all do |row|
          row.percentage_change.present? || row.national_percentage_change.present?
        end

        expect(rows_with_percentage_change.empty?).to be true
      end

      context 'regional report type' do
        let(:report_type) { :REGIONAL }

        it 'does not include percentage change data for each row' do
          provider_statistics = create(:provider_recruitment_performance_report).statistics
          regional_statistics = create(:regional_recruitment_performance_report).statistics

          rows = described_class.new(
            field_mapping: field_mapping_without_change,
            provider_statistics:,
            statistics: regional_statistics,
            type: report_type,
          ).subject_rows

          rows_with_percentage_change = rows.find_all do |row|
            row.percentage_change.present? || row.national_percentage_change.present?
          end

          expect(rows_with_percentage_change.empty?).to be true
        end
      end
    end

    describe 'a field mapping only include this cycle' do
      it 'only includes this cycle only data' do
        provider_statistics = create(:provider_recruitment_performance_report).statistics
        statistics = create(:national_recruitment_performance_report).statistics

        rows = described_class.new(
          field_mapping: field_mapping_this_cycle_only,
          provider_statistics:,
          statistics:,
          type: report_type,
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

      context 'regional report type' do
        let(:report_type) { :REGIONAL }

        it 'only includes this cycle only data' do
          provider_statistics = create(:provider_recruitment_performance_report).statistics
          regional_statistics = create(:regional_recruitment_performance_report).statistics

          rows = described_class.new(
            field_mapping: field_mapping_this_cycle_only,
            provider_statistics:,
            statistics: regional_statistics,
            type: report_type,
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
    end

    describe 'provider has primary only data' do
      it 'returns only primary rows' do
        provider_statistics = create(:provider_recruitment_performance_report, :primary_only).statistics
        statistics = create(:national_recruitment_performance_report).statistics

        rows = described_class.new(
          field_mapping: field_mapping_with_change,
          provider_statistics:,
          statistics:,
          type: report_type,
        ).subject_rows

        subjects = rows.map(&:title)
        expect(subjects).to contain_exactly('Primary')
      end

      context 'regional report type' do
        let(:report_type) { :REGIONAL }

        it 'returns only primary rows' do
          provider_statistics = create(:provider_recruitment_performance_report, :primary_only).statistics
          regional_statistics = create(:regional_recruitment_performance_report).statistics

          rows = described_class.new(
            field_mapping: field_mapping_with_change,
            provider_statistics:,
            statistics: regional_statistics,
            type: report_type,
          ).subject_rows

          subjects = rows.map(&:title)
          expect(subjects).to contain_exactly('Primary')
        end
      end
    end

    describe 'provider has only secondary data' do
      it 'returns only secondary rows' do
        provider_statistics = create(:provider_recruitment_performance_report, :secondary_only).statistics
        statistics = create(:national_recruitment_performance_report).statistics

        rows = described_class.new(
          field_mapping: field_mapping_without_change,
          provider_statistics:,
          statistics:,
          type: report_type,
        ).subject_rows

        subjects = rows.map(&:title)
        expect(subjects).to contain_exactly('Secondary', 'Art & Design', 'Biology', 'Chemistry', 'Computing',
                                            'Design & Technology', 'Drama', 'English', 'Geography', 'History',
                                            'Mathematics', 'Modern Foreign Languages', 'Music', 'Others',
                                            'Physical Education', 'Physics', 'Religious Education')
      end

      context 'regional report type' do
        let(:report_type) { :REGIONAL }

        it 'returns only secondary rows' do
          provider_statistics = create(:provider_recruitment_performance_report, :secondary_only).statistics
          regional_statistics = create(:regional_recruitment_performance_report).statistics

          rows = described_class.new(
            field_mapping: field_mapping_without_change,
            provider_statistics:,
            statistics: regional_statistics,
            type: report_type,
          ).subject_rows

          subjects = rows.map(&:title)
          expect(subjects).to contain_exactly('Secondary', 'Art & Design', 'Biology', 'Chemistry', 'Computing',
                                              'Design & Technology', 'Drama', 'English', 'Geography', 'History',
                                              'Mathematics', 'Modern Foreign Languages', 'Music', 'Others',
                                              'Physical Education', 'Physics', 'Religious Education')
        end
      end
    end

    it 'returns rows ordered by level and then title' do
      provider_statistics = create(:provider_recruitment_performance_report).statistics
      statistics = create(:national_recruitment_performance_report).statistics
      rows = described_class.new(
        field_mapping: field_mapping_without_change,
        provider_statistics:,
        statistics:,
        type: report_type,
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

    context 'regional report type' do
      let(:report_type) { :REGIONAL }

      it 'returns rows ordered by level and then title' do
        provider_statistics = create(:provider_recruitment_performance_report).statistics
        regional_statistics = create(:regional_recruitment_performance_report).statistics

        rows = described_class.new(
          field_mapping: field_mapping_without_change,
          provider_statistics:,
          statistics: regional_statistics,
          type: report_type,
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
end
