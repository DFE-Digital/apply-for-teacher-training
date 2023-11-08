require 'rails_helper'

RSpec.describe DfE::Bigquery::ApplicationMetrics do
  let(:client) { instance_double(Google::Cloud::Bigquery::Project) }

  before { set_time(Time.zone.local(2023, 11, 20)) }

  describe '.candidate_headline_statistics' do
    subject(:application_metrics) do
      described_class.candidate_headline_statistics(cycle_week: 7)
    end

    let(:results) do
      [
        {
          number_of_candidates_submitted_to_date: 100,
          cycle_week: 7,
        },
      ]
    end

    before do
      allow(DfE::Bigquery).to receive(:client).and_return(client)
      allow(client).to receive(:query)
        .with(
          <<~SQL,
            SELECT *
            FROM dataform.application_metrics
            WHERE recruitment_cycle_year = 2024
            AND cycle_week = 7
            AND subject_filter_category = "Total excluding Further Education"
            AND nonsubject_filter_category = "Total"
          SQL
        )
        .and_return(results)
    end

    it 'instantiate an application metrics' do
      expect(application_metrics).to be_instance_of(described_class)
    end

    it 'assigns the attributes for the application metrics' do
      expect(application_metrics.number_of_candidates_submitted_to_date).to be 100
      expect(application_metrics.cycle_week).to be 7
    end
  end

  describe '.age_group' do
    subject(:application_metrics) do
      described_class.age_group(cycle_week: 7)
    end

    let(:results) do
      [
        {
          number_of_candidates_submitted_to_date: 100,
          nonsubject_filter: '25 to 29',
          cycle_week: 7,
        },
      ]
    end

    before do
      allow(DfE::Bigquery).to receive(:client).and_return(client)
      allow(client).to receive(:query)
        .with(
          <<~SQL,
            SELECT *
            FROM dataform.application_metrics
            WHERE recruitment_cycle_year = 2024
            AND cycle_week = 7
            AND subject_filter_category = "Total excluding Further Education"
            AND nonsubject_filter_category = "Age group"
            ORDER BY nonsubject_filter ASC
          SQL
        )
        .and_return(results)
    end

    it 'instantiate an application metrics' do
      expect(application_metrics).to be_instance_of(Array)
      expect(application_metrics.size).to be 1
    end

    it 'assigns the attributes for the application metrics' do
      expect(application_metrics.first.number_of_candidates_submitted_to_date).to be 100
      expect(application_metrics.first.cycle_week).to be 7
      expect(application_metrics.first.nonsubject_filter).to eq('25 to 29')
    end
  end
end
