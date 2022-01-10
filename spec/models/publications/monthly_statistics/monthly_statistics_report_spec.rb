require 'rails_helper'

RSpec.describe Publications::MonthlyStatistics::MonthlyStatisticsReport do
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
      course_age_group_monthly_statistics_double = instance_double(Publications::MonthlyStatistics::ByCourseAgeGroup)
      area_monthly_statistics_double = instance_double(Publications::MonthlyStatistics::ByArea)
      sex_group_monthly_statistics_double = instance_double(Publications::MonthlyStatistics::BySex)
      applications_by_status_monthly_statistics_double = instance_double(Publications::MonthlyStatistics::ByStatus)
      candidates_by_status_monthly_statistics_double = instance_double(Publications::MonthlyStatistics::ByStatus)
      course_type_monthly_statistics_double = instance_double(Publications::MonthlyStatistics::ByCourseType)
      applications_by_primary_specialist_subject_double = instance_double(Publications::MonthlyStatistics::ByPrimarySpecialistSubject)
      by_age_group_monthly_statistics_double = instance_double(Publications::MonthlyStatistics::ByAgeGroup)
      applications_by_secondary_subject_double = instance_double(Publications::MonthlyStatistics::BySecondarySubject)
      applications_by_provider_area_double = instance_double(Publications::MonthlyStatistics::ByProviderArea)
      deferred_applications_double = instance_double(Publications::MonthlyStatistics::DeferredApplications)

      table_data = [{ 'foo' => 'bar' }]

      allow(Publications::MonthlyStatistics::ByCourseAgeGroup).to receive(:new).and_return(course_age_group_monthly_statistics_double)
      allow(Publications::MonthlyStatistics::ByArea).to receive(:new).and_return(area_monthly_statistics_double)
      allow(Publications::MonthlyStatistics::BySex).to receive(:new).and_return(sex_group_monthly_statistics_double)
      allow(Publications::MonthlyStatistics::ByStatus).to receive(:new).and_return(applications_by_status_monthly_statistics_double)
      allow(Publications::MonthlyStatistics::ByStatus).to receive(:new).with(by_candidate: true).and_return(candidates_by_status_monthly_statistics_double)
      allow(Publications::MonthlyStatistics::ByCourseType).to receive(:new).and_return(course_type_monthly_statistics_double)
      allow(Publications::MonthlyStatistics::ByPrimarySpecialistSubject).to receive(:new).and_return(applications_by_primary_specialist_subject_double)
      allow(Publications::MonthlyStatistics::ByAgeGroup).to receive(:new).and_return(by_age_group_monthly_statistics_double)
      allow(Publications::MonthlyStatistics::BySecondarySubject).to receive(:new).and_return(applications_by_secondary_subject_double)
      allow(Publications::MonthlyStatistics::ByProviderArea).to receive(:new).and_return(applications_by_provider_area_double)
      allow(Publications::MonthlyStatistics::DeferredApplications).to receive(:new).and_return(deferred_applications_double)

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
      allow(deferred_applications_double).to receive(:count).and_return(57)

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
        'deferred_applications_count' => 57,
      )
    end
  end
end
