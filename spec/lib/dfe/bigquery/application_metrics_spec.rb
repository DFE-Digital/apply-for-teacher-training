require 'rails_helper'

RSpec.describe DfE::Bigquery::ApplicationMetrics do
  let(:client) { instance_double(Google::Cloud::Bigquery::Project) }

  before do
    set_time(Time.zone.local(2023, 11, 20))
    allow(DfE::Bigquery).to receive(:client).and_return(client)
  end

  describe '.candidate_headline_statistics' do
    subject(:application_metrics) do
      described_class.new(cycle_week: 7).candidate_headline_statistics
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

    it 'returns the first result' do
      expect(application_metrics.as_json).to eq(results.first.as_json)
    end

    it 'assigns the attributes for the application metrics' do
      expect(application_metrics.number_of_candidates_submitted_to_date).to be 100
      expect(application_metrics.cycle_week).to be 7
    end
  end

  describe '.age_group' do
    subject(:application_metrics) do
      described_class.new(cycle_week: 7).age_group
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
      allow(client).to receive(:query)
        .with(
          <<~SQL,
            SELECT *
            FROM dataform.application_metrics
            WHERE recruitment_cycle_year = 2024
            AND cycle_week = 7
            AND subject_filter_category = "Total excluding Further Education"
            AND nonsubject_filter_category = "Age group"
            ORDER BY (
              CASE WHEN nonsubject_filter='Prefer not to say' THEN 4
                   WHEN nonsubject_filter='Unknown' THEN 3
                   WHEN nonsubject_filter='Other' OR nonsubject_filter='Others' THEN 2
                   ELSE 1
              END
            )
            , nonsubject_filter ASC
          SQL
        )
        .and_return(results)
    end

    it 'returns the correct results' do
      expect(application_metrics.as_json).to eq(results.as_json)
    end

    it 'assigns the attributes for the application metrics' do
      expect(application_metrics.first.number_of_candidates_submitted_to_date).to be 100
      expect(application_metrics.first.cycle_week).to be 7
      expect(application_metrics.first.nonsubject_filter).to eq('25 to 29')
    end
  end

  describe '.sex' do
    subject(:application_metrics) do
      described_class.new(cycle_week: 7).sex
    end

    let(:results) do
      [
        {
          nonsubject_filter: 'Male',
          cycle_week: 7,
        },
        {
          nonsubject_filter: 'Female',
          cycle_week: 7,
        },
        {
          nonsubject_filter: 'Prefer not to say',
          cycle_week: 7,
        },
        {
          nonsubject_filter: 'Other',
          cycle_week: 7,
        },
      ]
    end

    before do
      allow(client).to receive(:query)
        .with(
          <<~SQL,
            SELECT *
            FROM dataform.application_metrics
            WHERE recruitment_cycle_year = 2024
            AND cycle_week = 7
            AND subject_filter_category = "Total excluding Further Education"
            AND nonsubject_filter_category = "Sex"
            ORDER BY (
              CASE WHEN nonsubject_filter='Prefer not to say' THEN 4
                   WHEN nonsubject_filter='Unknown' THEN 3
                   WHEN nonsubject_filter='Other' OR nonsubject_filter='Others' THEN 2
                   ELSE 1
              END
            )
            , nonsubject_filter ASC
          SQL
        )
        .and_return(results)
    end

    it 'returns the correct results' do
      expect(application_metrics.as_json).to eq(results.as_json)
    end

    it 'assigns the attributes for the application metrics' do
      expect(application_metrics.first.cycle_week).to be 7
      expect(application_metrics.first.nonsubject_filter).to eq('Male')
    end
  end

  describe '.area' do
    subject(:application_metrics) do
      described_class.new(cycle_week: 7).area
    end

    let(:results) do
      [
        {
          nonsubject_filter: 'London',
          cycle_week: 7,
        },
        {
          nonsubject_filter: 'European Economic area',
          cycle_week: 7,
        },
      ]
    end

    before do
      allow(client).to receive(:query)
        .with(
          <<~SQL,
            SELECT *
            FROM dataform.application_metrics
            WHERE recruitment_cycle_year = 2024
            AND cycle_week = 7
            AND subject_filter_category = "Total excluding Further Education"
            AND nonsubject_filter_category = "Candidate region"
            ORDER BY (
              CASE WHEN nonsubject_filter='Prefer not to say' THEN 4
                   WHEN nonsubject_filter='Unknown' THEN 3
                   WHEN nonsubject_filter='Other' OR nonsubject_filter='Others' THEN 2
                   ELSE 1
              END
            )
            , nonsubject_filter ASC
          SQL
        )
        .and_return(results)
    end

    it 'returns the correct results' do
      expect(application_metrics.as_json).to eq(results.as_json)
    end

    it 'assigns the attributes for the application metrics' do
      expect(application_metrics.first.cycle_week).to be 7
      expect(application_metrics.first.nonsubject_filter).to eq('London')
    end
  end

  describe '.phase' do
    subject(:application_metrics) do
      described_class.new(cycle_week: 7).phase
    end

    let(:results) do
      [
        {
          subject_filter: 'Primary',
          cycle_week: 7,
        },
        {
          subject_filter: 'Secondary',
          cycle_week: 7,
        },
      ]
    end

    before do
      allow(client).to receive(:query)
        .with(
          <<~SQL,
            SELECT *
            FROM dataform.application_metrics
            WHERE recruitment_cycle_year = 2024
            AND cycle_week = 7
            AND subject_filter_category = "Level"
            AND nonsubject_filter_category = "Total"
            AND subject_filter != "Further Education"
            ORDER BY (
              CASE WHEN subject_filter='Prefer not to say' THEN 4
                   WHEN subject_filter='Unknown' THEN 3
                   WHEN subject_filter='Other' OR subject_filter='Others' THEN 2
                   ELSE 1
              END
            )
            , subject_filter ASC
          SQL
        )
        .and_return(results)
    end

    it 'returns the correct results' do
      expect(application_metrics.as_json).to eq(results.as_json)
    end

    it 'assigns the attributes for the application metrics' do
      expect(application_metrics.first.cycle_week).to be 7
      expect(application_metrics.first.subject_filter).to eq('Primary')
      expect(application_metrics.last.subject_filter).to eq('Secondary')
    end
  end

  describe '.route_into_teaching' do
    subject(:application_metrics) do
      described_class.new(cycle_week: 7).route_into_teaching
    end

    let(:results) do
      [
        {
          nonsubject_filter: 'Postgraduate teaching apprenticeship',
          cycle_week: 7,
        },
        {
          nonsubject_filter: 'School Direct (salaried)',
          cycle_week: 7,
        },
      ]
    end

    before do
      allow(client).to receive(:query)
        .with(
          <<~SQL,
            SELECT *
            FROM dataform.application_metrics
            WHERE recruitment_cycle_year = 2024
            AND cycle_week = 7
            AND subject_filter_category = "Total excluding Further Education"
            AND nonsubject_filter_category = "Route into teaching"
            ORDER BY (
              CASE WHEN nonsubject_filter='Prefer not to say' THEN 4
                   WHEN nonsubject_filter='Unknown' THEN 3
                   WHEN nonsubject_filter='Other' OR nonsubject_filter='Others' THEN 2
                   ELSE 1
              END
            )
            , nonsubject_filter ASC
          SQL
        )
        .and_return(results)
    end

    it 'returns the correct results' do
      expect(application_metrics.as_json).to eq(results.as_json)
    end

    it 'assigns the attributes for the application metrics' do
      expect(application_metrics.first.cycle_week).to be 7
      expect(application_metrics.first.nonsubject_filter).to eq('Postgraduate teaching apprenticeship')
      expect(application_metrics.last.nonsubject_filter).to eq('School Direct (salaried)')
    end
  end

  describe '.primary_subject' do
    subject(:application_metrics) do
      described_class.new(cycle_week: 7).primary_subject
    end

    let(:results) do
      [
        {
          subject_filter: 'Primary with English',
          cycle_week: 7,
        },
        {
          subject_filter: 'Primary with Science',
          cycle_week: 7,
        },
      ]
    end

    before do
      allow(client).to receive(:query)
        .with(
          <<~SQL,
            SELECT *
            FROM dataform.application_metrics
            WHERE recruitment_cycle_year = 2024
            AND cycle_week = 7
            AND subject_filter_category = "Primary subject"
            AND nonsubject_filter_category = "Total"
            ORDER BY (
              CASE WHEN subject_filter='Prefer not to say' THEN 4
                   WHEN subject_filter='Unknown' THEN 3
                   WHEN subject_filter='Other' OR subject_filter='Others' THEN 2
                   ELSE 1
              END
            )
            , subject_filter ASC
          SQL
        )
        .and_return(results)
    end

    it 'returns the correct results' do
      expect(application_metrics.as_json).to eq(results.as_json)
    end

    it 'assigns the attributes for the application metrics' do
      expect(application_metrics.first.cycle_week).to be 7
      expect(application_metrics.first.subject_filter).to eq('Primary with English')
      expect(application_metrics.last.subject_filter).to eq('Primary with Science')
    end
  end

  describe '.secondary_subject' do
    subject(:application_metrics) do
      described_class.new(cycle_week: 7).secondary_subject
    end

    let(:results) do
      [
        {
          subject_filter: 'Magic tricks',
          cycle_week: 7,
        },
        {
          subject_filter: 'Illusion tricks',
          cycle_week: 7,
        },
      ]
    end

    before do
      allow(client).to receive(:query)
        .with(
          <<~SQL,
            SELECT *
            FROM dataform.application_metrics
            WHERE recruitment_cycle_year = 2024
            AND cycle_week = 7
            AND subject_filter_category = "Secondary subject excluding Further Education"
            AND nonsubject_filter_category = "Total"
            ORDER BY (
              CASE WHEN subject_filter='Prefer not to say' THEN 4
                   WHEN subject_filter='Unknown' THEN 3
                   WHEN subject_filter='Other' OR subject_filter='Others' THEN 2
                   ELSE 1
              END
            )
            , subject_filter ASC
          SQL
        )
        .and_return(results)
    end

    it 'returns the correct results' do
      expect(application_metrics.as_json).to eq(results.as_json)
    end

    it 'assigns the attributes for the application metrics' do
      expect(application_metrics.first.cycle_week).to be 7
      expect(application_metrics.first.subject_filter).to eq('Magic tricks')
      expect(application_metrics.last.subject_filter).to eq('Illusion tricks')
    end
  end

  describe '.provider_region' do
    subject(:application_metrics) do
      described_class.new(cycle_week: 7).provider_region
    end

    let(:results) do
      [
        {
          nonsubject_filter: 'Gondor',
          cycle_week: 7,
        },
        {
          nonsubject_filter: 'Mordor',
          cycle_week: 7,
        },
      ]
    end

    before do
      allow(client).to receive(:query)
        .with(
          <<~SQL,
            SELECT *
            FROM dataform.application_metrics
            WHERE recruitment_cycle_year = 2024
            AND cycle_week = 7
            AND subject_filter_category = "Total excluding Further Education"
            AND nonsubject_filter_category = "Provider region"
            ORDER BY (
              CASE WHEN nonsubject_filter='Prefer not to say' THEN 4
                   WHEN nonsubject_filter='Unknown' THEN 3
                   WHEN nonsubject_filter='Other' OR nonsubject_filter='Others' THEN 2
                   ELSE 1
              END
            )
            , nonsubject_filter ASC
          SQL
        )
        .and_return(results)
    end

    it 'returns the correct results' do
      expect(application_metrics.as_json).to eq(results.as_json)
    end

    it 'assigns the attributes for the application metrics' do
      expect(application_metrics.first.cycle_week).to be 7
      expect(application_metrics.first.nonsubject_filter).to eq('Gondor')
      expect(application_metrics.last.nonsubject_filter).to eq('Mordor')
    end
  end
end
