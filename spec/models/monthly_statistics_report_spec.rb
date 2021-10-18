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
      sex_group_monthly_statistics_double = instance_double(MonthlyStatistics::BySex)
      applications_by_status_monthly_statistics_double = instance_double(MonthlyStatistics::ByStatus)
      candidates_by_status_monthly_statistics_double = instance_double(MonthlyStatistics::ByStatus)
      applications_by_primary_specialist_subject_double = instance_double(MonthlyStatistics::ByPrimarySpecialistSubject)
      table_data = [{ 'foo' => 'bar' }]

      allow(MonthlyStatistics::ByCourseAgeGroup).to receive(:new).and_return(course_age_group_monthly_statistics_double)
      allow(MonthlyStatistics::BySex).to receive(:new).and_return(sex_group_monthly_statistics_double)
      allow(MonthlyStatistics::ByStatus).to receive(:new).and_return(applications_by_status_monthly_statistics_double)
      allow(MonthlyStatistics::ByStatus).to receive(:new).with(by_candidate: true).and_return(candidates_by_status_monthly_statistics_double)
      allow(MonthlyStatistics::ByPrimarySpecialistSubject).to receive(:new).and_return(applications_by_primary_specialist_subject_double)

      allow(course_age_group_monthly_statistics_double).to receive(:table_data).and_return(table_data)
      allow(sex_group_monthly_statistics_double).to receive(:table_data).and_return(table_data)
      allow(applications_by_status_monthly_statistics_double).to receive(:table_data).and_return(table_data)
      allow(candidates_by_status_monthly_statistics_double).to receive(:table_data).and_return(table_data)
      allow(applications_by_primary_specialist_subject_double).to receive(:table_data).and_return(table_data)

      report = described_class.new
      report.load_table_data

      expect(report.statistics).to eq(
        'by_course_age_group' => table_data,
        'by_sex' => table_data,
        'applications_by_status' => table_data,
        'candidates_by_status' => table_data,
        'by_primary_specialist_subject' => table_data,
      )
    end
  end
end
