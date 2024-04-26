require 'rails_helper'

RSpec.describe DfE::Bigquery::ApplicationMetricsByProvider do
  let(:client) { instance_double(Google::Cloud::Bigquery::Project) }

  before do
    allow(DfE::Bigquery).to receive(:client).and_return(client)
  end

  describe '.candidate_all' do
    subject(:provider_statistics) do
      described_class.new(cycle_week: 18, provider_id: 1337).candidate_all
    end

    let(:results) do
      [
        {
          number_of_candidates_submitted_to_date: 100,
          provider_id: 1337,
          cycle_week: 18,
          recruitment_cycle_year: 2024,
        },
      ]
    end

    before do
      allow(client).to receive(:query)
        .with(<<~SQL).and_return(results)
          SELECT nonprovider_filter, nonprovider_filter_category, cycle_week, recruitment_cycle_year, provider.id, number_of_candidates_submitted_to_date, number_of_candidates_submitted_to_same_date_previous_cycle, number_of_candidates_submitted_to_date_as_proportion_of_last_cycle, number_of_candidates_with_offers_to_date, number_of_candidates_with_offers_to_same_date_previous_cycle, number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle, number_of_candidates_accepted_to_date, number_of_candidates_accepted_to_same_date_previous_cycle, number_of_candidates_accepted_to_date_as_proportion_of_last_cycle, number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date, number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle, number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle, number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date, number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle, number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle, number_of_candidates_who_had_an_inactive_application_this_cycle_to_date, number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates
          FROM dataform.application_metrics_by_provider
          WHERE provider.id = "1337"
          AND cycle_week = 18
          AND recruitment_cycle_year = 2024
          AND (
            nonprovider_filter_category = "Secondary subject"
            OR (nonprovider_filter_category = "Level" AND nonprovider_filter IN ("Primary", "Secondary"))
            OR nonprovider_filter = "All"
          )
        SQL
    end

    it 'returns the first result' do
      expect(provider_statistics.as_json).to eq(results.as_json)
    end

    it 'assigns the attributes for the application metrics' do
      expect(provider_statistics.first.number_of_candidates_submitted_to_date).to be 100
      expect(provider_statistics.first.cycle_week).to be 18
      expect(provider_statistics.first.provider_id).to be 1337
      expect(provider_statistics.first.recruitment_cycle_year).to be 2024
    end
  end

  describe '.candidate_submitted_to_date' do
    subject(:provider_statistics) do
      described_class.new(cycle_week: 18, provider_id: 1337).candidate_submitted_to_date
    end

    let(:results) do
      [
        {
          number_of_candidates_submitted_to_date: 10,
          number_of_candidates_submitted_to_same_date_previous_cycle: 100,
          number_of_candidates_submitted_to_date_as_proportion_of_last_cycle: 0.1,
          provider_id: 1337,
          cycle_week: 18,
          recruitment_cycle_year: 2024,
        },
      ]
    end

    before do
      allow(client).to receive(:query)
        .with(<<~SQL).and_return(results)
          SELECT nonprovider_filter, nonprovider_filter_category, cycle_week, recruitment_cycle_year, provider.id, number_of_candidates_submitted_to_date, number_of_candidates_submitted_to_same_date_previous_cycle, number_of_candidates_submitted_to_date_as_proportion_of_last_cycle
          FROM dataform.application_metrics_by_provider
          WHERE provider.id = "1337"
          AND cycle_week = 18
          AND recruitment_cycle_year = 2024
          AND (nonprovider_filter_category IN ("Secondary subject", "Primary subject") OR nonprovider_filter IN ("Primary", "Secondary"))
        SQL
    end

    it 'returns the first result' do
      expect(provider_statistics.as_json).to eq(results.as_json)
    end

    it 'assigns the attributes for the application metrics' do
      expect(provider_statistics.first.number_of_candidates_submitted_to_date).to be 10
      expect(provider_statistics.first.number_of_candidates_submitted_to_same_date_previous_cycle).to be 100
      expect(provider_statistics.first.number_of_candidates_submitted_to_date_as_proportion_of_last_cycle).to be 0.1
      expect(provider_statistics.first.cycle_week).to be 18
      expect(provider_statistics.first.provider_id).to be 1337
      expect(provider_statistics.first.recruitment_cycle_year).to be 2024
    end
  end

  describe '.national_all_query' do
    subject(:provider_statistics) do
      described_class.new(cycle_week: 18).national_all
    end

    let(:results) do
      [
        {
          nonprovider_filter: 'All',
          nonprovider_filter_category: 'All',
          number_of_candidates_submitted_to_date: 10,
          number_of_candidates_submitted_to_same_date_previous_cycle: 100,
          number_of_candidates_submitted_to_date_as_proportion_of_last_cycle: 0.1,
          cycle_week: 18,
          recruitment_cycle_year: 2024,
        },
      ]
    end

    before do
      allow(client).to receive(:query)
        .with(<<~SQL).and_return(results)
          SELECT nonprovider_filter, nonprovider_filter_category, cycle_week, recruitment_cycle_year, provider.id, number_of_candidates_submitted_to_date, number_of_candidates_submitted_to_same_date_previous_cycle, number_of_candidates_submitted_to_date_as_proportion_of_last_cycle, number_of_candidates_with_offers_to_date, number_of_candidates_with_offers_to_same_date_previous_cycle, number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle, number_of_candidates_accepted_to_date, number_of_candidates_accepted_to_same_date_previous_cycle, number_of_candidates_accepted_to_date_as_proportion_of_last_cycle, number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date, number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle, number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle, number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date, number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle, number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle, number_of_candidates_who_had_an_inactive_application_this_cycle_to_date, number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates
          FROM dataform.application_metrics_by_provider
          WHERE cycle_week = 18
          AND recruitment_cycle_year = 2024
          AND teach_first_or_iot_filter = "All"
          AND provider_filter_category = "All"
          AND (
            nonprovider_filter_category = "Secondary subject"
            OR (nonprovider_filter_category = "Level" AND nonprovider_filter IN ("Primary", "Secondary"))
            OR (nonprovider_filter = "All")
          )
        SQL
    end

    it 'returns the first result' do
      expect(provider_statistics.as_json).to eq(results.as_json)
    end

    it 'assigns the attributes for the application metrics' do
      expect(provider_statistics.first.number_of_candidates_submitted_to_date).to be 10
      expect(provider_statistics.first.number_of_candidates_submitted_to_same_date_previous_cycle).to be 100
      expect(provider_statistics.first.number_of_candidates_submitted_to_date_as_proportion_of_last_cycle).to be 0.1
      expect(provider_statistics.first.cycle_week).to be 18
      expect(provider_statistics.first.provider_id).to be_nil
      expect(provider_statistics.first.nonprovider_filter_category).to eq('All')
      expect(provider_statistics.first.nonprovider_filter).to eq('All')
      expect(provider_statistics.first.recruitment_cycle_year).to be 2024
    end
  end
end
