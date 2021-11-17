require 'rails_helper'

RSpec.describe MonthlyStatisticsReport do
  describe '#write_metric' do
    context 'the #statistics attribute is nil' do
      let(:report) { described_class.new }

      it 'writes the given key/value pair' do
        report.write_statistic(:test, :value)
        expect(report.statistics).to eq('test' => 'value')
      end
    end

    context 'the #statistics attribute already contains a hash' do
      let(:report) { described_class.new(statistics: { existing: :value }) }

      it 'adds new values' do
        report.write_statistic(:new, :value)
        expect(report.statistics).to eq(
          'existing' => 'value',
          'new' => 'value',
        )
      end

      it 'overrides existing values' do
        report.write_statistic(:existing, :changed_value)
        expect(report.statistics).to eq('existing' => 'changed_value')
      end
    end
  end

  describe '#read_metric' do
    let(:report) { described_class.new(statistics: { 'test' => 'value' }) }

    it 'returns the matching value' do
      expect(report.read_statistic('test')).to eq 'value'
    end

    it 'accepts key names as both strings and symbols' do
      expect(report.read_statistic(:test)).to eq 'value'
    end

    it 'returns a placeholder "missing value" if the key is not found' do
      expect(report.read_statistic(:testttt)).to eq 'n/a'
    end
  end

  describe '#load_updated_statistics' do
    it 'retrieves all required statistics' do
      course_age_group_monthly_statistics_double = instance_double(MonthlyStatistics::ByCourseAgeGroup)
      area_monthly_statistics_double = instance_double(MonthlyStatistics::ByArea)
      sex_group_monthly_statistics_double = instance_double(MonthlyStatistics::BySex)
      applications_by_status_monthly_statistics_double = instance_double(MonthlyStatistics::ByStatus)
      candidates_by_status_monthly_statistics_double = instance_double(MonthlyStatistics::ByStatus)
      course_type_monthly_statistics_double = instance_double(MonthlyStatistics::ByCourseType)
      applications_by_primary_specialist_subject_double = instance_double(MonthlyStatistics::ByPrimarySpecialistSubject)
      by_age_group_monthly_statistics_double = instance_double(MonthlyStatistics::ByAgeGroup)
      applications_by_secondary_subject_double = instance_double(MonthlyStatistics::BySecondarySubject)
      applications_by_provider_area_double = instance_double(MonthlyStatistics::ByProviderArea)

      table_data = [{ 'foo' => 'bar' }]

      allow(MonthlyStatistics::ByCourseAgeGroup).to receive(:new).and_return(course_age_group_monthly_statistics_double)
      allow(MonthlyStatistics::ByArea).to receive(:new).and_return(area_monthly_statistics_double)
      allow(MonthlyStatistics::BySex).to receive(:new).and_return(sex_group_monthly_statistics_double)
      allow(MonthlyStatistics::ByStatus).to receive(:new).and_return(applications_by_status_monthly_statistics_double)
      allow(MonthlyStatistics::ByStatus).to receive(:new).with(by_candidate: true).and_return(candidates_by_status_monthly_statistics_double)
      allow(MonthlyStatistics::ByCourseType).to receive(:new).and_return(course_type_monthly_statistics_double)
      allow(MonthlyStatistics::ByPrimarySpecialistSubject).to receive(:new).and_return(applications_by_primary_specialist_subject_double)
      allow(MonthlyStatistics::ByAgeGroup).to receive(:new).and_return(by_age_group_monthly_statistics_double)
      allow(MonthlyStatistics::BySecondarySubject).to receive(:new).and_return(applications_by_secondary_subject_double)
      allow(MonthlyStatistics::ByProviderArea).to receive(:new).and_return(applications_by_provider_area_double)

      allow(course_age_group_monthly_statistics_double).to receive(:table_data).and_return(table_data)
      allow(area_monthly_statistics_double).to receive(:table_data).and_return(table_data)
      allow(sex_group_monthly_statistics_double).to receive(:table_data).and_return(table_data)
      allow(course_type_monthly_statistics_double).to receive(:table_data).and_return(table_data)
      allow(applications_by_status_monthly_statistics_double).to receive(:table_data).and_return(table_data)
      allow(candidates_by_status_monthly_statistics_double).to receive(:table_data).and_return(table_data)
      allow(applications_by_primary_specialist_subject_double).to receive(:table_data).and_return(table_data)
      allow(by_age_group_monthly_statistics_double).to receive(:table_data).and_return(table_data)
      allow(applications_by_secondary_subject_double).to receive(:table_data).and_return(table_data)
      allow(applications_by_provider_area_double).to receive(:table_data).and_return(table_data)

      report = described_class.new
      report.load_table_data

      expect(report.statistics).to eq(
        'by_course_age_group' => table_data,
        'by_area' => table_data,
        'by_sex' => table_data,
        'applications_by_status' => table_data,
        'candidates_by_status' => table_data,
        'by_course_type' => table_data,
        'by_primary_specialist_subject' => table_data,
        'by_age_group' => table_data,
        'by_secondary_subject' => table_data,
        'by_provider_area' => table_data,
      )
    end
  end

  describe '#latest_publishable_report' do
    context 'when there are is only one monthly report' do
      it 'returns the report' do
        report = described_class.new
        report.save

        expect(described_class.latest_publishable_report).to eq report
      end
    end

    context 'when there are multiple reports and the MonthlyStatisticsTimetable returns false for #between_generation_and_publish_dates?' do
      it 'returns the latest report' do
        allow(MonthlyStatisticsTimetable).to receive(:between_generation_and_publish_dates?).and_return false
        report1 = described_class.new
        report1.save

        report2 = described_class.new
        report2.save

        expect(described_class.latest_publishable_report).to eq report2
      end
    end

    context 'when there are multiple reports and the MonthlyStatisticsTimetable returns true for #between_generation_and_publish_dates?' do
      it 'returns last months report' do
        allow(MonthlyStatisticsTimetable).to receive(:between_generation_and_publish_dates?).and_return true
        report1 = described_class.new
        report1.save

        report2 = described_class.new
        report2.save

        expect(described_class.latest_publishable_report).to eq report1
      end
    end
  end

  describe '#latest_publishable_exports' do
    context 'when it is not between the generation and publish date' do
      it 'returns the latest set of MonthlyStatistics exports' do
        allow(MonthlyStatisticsTimetable).to receive(:between_generation_and_publish_dates?).and_return false
        expected_reports = []

        DataExport::MONTHLY_STATISTICS_EXPORTS.each do |export_type|
          create(:data_export, export_type: export_type)
          expected_reports << create(:data_export, export_type: export_type)
        end

        expect(described_class.latest_publishable_exports).to eq expected_reports
      end
    end

    context 'when it is between the generation and publish date for the current month' do
      it 'returns the latest set of MonthlyStatistics exports' do
        allow(MonthlyStatisticsTimetable).to receive(:between_generation_and_publish_dates?).and_return true
        expected_reports = []

        DataExport::MONTHLY_STATISTICS_EXPORTS.each do |export_type|
          expected_reports << create(:data_export, export_type: export_type)
          create(:data_export, export_type: export_type)
        end

        expect(described_class.latest_publishable_exports).to eq expected_reports
      end
    end
  end
end
