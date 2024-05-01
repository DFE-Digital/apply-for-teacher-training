require 'rails_helper'

RSpec.describe DfE::Bigquery::ApplicationMetricsByProvider do
  let(:client) { instance_double(Google::Cloud::Bigquery::Project) }

  before do
    allow(DfE::Bigquery).to receive(:client).and_return(client)
  end

  describe '.provider_data' do
    subject(:provider_statistics) do
      described_class.new(cycle_week: 18, provider_id: 1337).provider_data
    end

    # Bigquery returns `provider.id` as :id
    let(:bigquery_results) do
      [
        {
          id: 1337,
          cycle_week: 18,
          recruitment_cycle_year: 2024,
          nonprovider_filter: 'Level',
          nonprovider_filter_category: 'Primary',
          number_of_candidates_submitted_to_date: 100,
          number_of_candidates_submitted_to_same_date_previous_cycle: 200,
          number_of_candidates_submitted_to_date_as_proportion_of_last_cycle: 0.5,
          number_of_candidates_with_offers_to_date: 10,
          number_of_candidates_with_offers_to_same_date_previous_cycle: 5,
          number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle: 2.0,
          offer_rate_to_date: 1.2,
          offer_rate_to_same_date_previous_cycle: 1.5,
          number_of_candidates_accepted_to_date: 1,
          number_of_candidates_accepted_to_same_date_previous_cycle: 10,
          number_of_candidates_accepted_to_date_as_proportion_of_last_cycle: 0.1,
          number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date: 12,
          number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle: 12,
          number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle: 0,
          number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date: 12,
          number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle: 12,
          number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle: 0,
          number_of_candidates_who_had_an_inactive_application_this_cycle_to_date: 12,
          number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates: 12,
        },
      ]
    end

    let(:results) do
      [
        {
          provider_id: 1337,
          cycle_week: 18,
          recruitment_cycle_year: 2024,
          nonprovider_filter: 'Level',
          nonprovider_filter_category: 'Primary',
          number_of_candidates_submitted_to_date: 100,
          number_of_candidates_submitted_to_same_date_previous_cycle: 200,
          number_of_candidates_submitted_to_date_as_proportion_of_last_cycle: 0.5,
          number_of_candidates_with_offers_to_date: 10,
          number_of_candidates_with_offers_to_same_date_previous_cycle: 5,
          number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle: 2.0,
          offer_rate_to_date: 1.2,
          offer_rate_to_same_date_previous_cycle: 1.5,
          number_of_candidates_accepted_to_date: 1,
          number_of_candidates_accepted_to_same_date_previous_cycle: 10,
          number_of_candidates_accepted_to_date_as_proportion_of_last_cycle: 0.1,
          number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date: 12,
          number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle: 12,
          number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle: 0,
          number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date: 12,
          number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle: 12,
          number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle: 0,
          number_of_candidates_who_had_an_inactive_application_this_cycle_to_date: 12,
          number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates: 12,
        },
      ]
    end

    before do
      allow(client).to receive(:query)
        .with(<<~SQL).and_return(bigquery_results)
          SELECT nonprovider_filter, nonprovider_filter_category, cycle_week, recruitment_cycle_year, provider.id, number_of_candidates_submitted_to_date, number_of_candidates_submitted_to_same_date_previous_cycle, number_of_candidates_submitted_to_date_as_proportion_of_last_cycle, number_of_candidates_with_offers_to_date, number_of_candidates_with_offers_to_same_date_previous_cycle, number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle, offer_rate_to_date, offer_rate_to_same_date_previous_cycle, number_of_candidates_accepted_to_date, number_of_candidates_accepted_to_same_date_previous_cycle, number_of_candidates_accepted_to_date_as_proportion_of_last_cycle, number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date, number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle, number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle, number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date, number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle, number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle, number_of_candidates_who_had_an_inactive_application_this_cycle_to_date, number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates
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

    it 'assigns the attributes for the application metrics', :aggregate_failures do
      expect(provider_statistics.first.nonprovider_filter).to eq 'Level'
      expect(provider_statistics.first.nonprovider_filter_category).to eq 'Primary'
      expect(provider_statistics.first.cycle_week).to eq 18
      expect(provider_statistics.first.recruitment_cycle_year).to eq 2024
      expect(provider_statistics.first.provider_id).to eq 1337
      expect(provider_statistics.first.number_of_candidates_submitted_to_date).to eq 100
      expect(provider_statistics.first.number_of_candidates_submitted_to_same_date_previous_cycle).to eq 200
      expect(provider_statistics.first.number_of_candidates_submitted_to_date_as_proportion_of_last_cycle).to eq 0.5
      expect(provider_statistics.first.number_of_candidates_with_offers_to_date).to eq 10
      expect(provider_statistics.first.number_of_candidates_with_offers_to_same_date_previous_cycle).to eq 5
      expect(provider_statistics.first.number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle).to eq 2
      expect(provider_statistics.first.number_of_candidates_accepted_to_date).to eq 1
      expect(provider_statistics.first.number_of_candidates_accepted_to_same_date_previous_cycle).to eq 10
      expect(provider_statistics.first.number_of_candidates_accepted_to_date_as_proportion_of_last_cycle).to eq 0.1
      expect(provider_statistics.first.number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date).to eq 12
      expect(provider_statistics.first.number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle).to eq 12
      expect(provider_statistics.first.number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle).to eq 0
      expect(provider_statistics.first.number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date).to eq 12
      expect(provider_statistics.first.number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle).to eq 12
      expect(provider_statistics.first.number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle).to eq 0
      expect(provider_statistics.first.number_of_candidates_who_had_an_inactive_application_this_cycle_to_date).to eq 12
      expect(provider_statistics.first.number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates).to eq 12
      expect(provider_statistics.first.number_of_candidates_submitted_to_date).to be 100
    end
  end

  describe '.national_data' do
    subject(:provider_statistics) do
      described_class.new(cycle_week: 18).national_data
    end

    let(:results) do
      [
        {
          cycle_week: 18,
          recruitment_cycle_year: 2024,
          nonprovider_filter: 'Level',
          nonprovider_filter_category: 'Primary',
          number_of_candidates_submitted_to_date: 100,
          number_of_candidates_submitted_to_same_date_previous_cycle: 200,
          number_of_candidates_submitted_to_date_as_proportion_of_last_cycle: 0.5,
          number_of_candidates_with_offers_to_date: 10,
          number_of_candidates_with_offers_to_same_date_previous_cycle: 5,
          number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle: 2.0,
          offer_rate_to_date: 1.2,
          offer_rate_to_same_date_previous_cycle: 1.5,
          number_of_candidates_accepted_to_date: 1,
          number_of_candidates_accepted_to_same_date_previous_cycle: 10,
          number_of_candidates_accepted_to_date_as_proportion_of_last_cycle: 0.1,
          number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date: 12,
          number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle: 12,
          number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle: 0,
          number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date: 12,
          number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle: 12,
          number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle: 0,
          number_of_candidates_who_had_an_inactive_application_this_cycle_to_date: 12,
          number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates: 12,
        },

      ]
    end

    before do
      allow(client).to receive(:query)
        .with(<<~SQL).and_return(results)
          SELECT nonprovider_filter, nonprovider_filter_category, cycle_week, recruitment_cycle_year, provider.id, number_of_candidates_submitted_to_date, number_of_candidates_submitted_to_same_date_previous_cycle, number_of_candidates_submitted_to_date_as_proportion_of_last_cycle, number_of_candidates_with_offers_to_date, number_of_candidates_with_offers_to_same_date_previous_cycle, number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle, offer_rate_to_date, offer_rate_to_same_date_previous_cycle, number_of_candidates_accepted_to_date, number_of_candidates_accepted_to_same_date_previous_cycle, number_of_candidates_accepted_to_date_as_proportion_of_last_cycle, number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date, number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle, number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle, number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date, number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle, number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle, number_of_candidates_who_had_an_inactive_application_this_cycle_to_date, number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates
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

    it 'assigns the attributes for the application metrics', :aggregate_failures do
      expect(provider_statistics.first.nonprovider_filter).to eq 'Level'
      expect(provider_statistics.first.nonprovider_filter_category).to eq 'Primary'
      expect(provider_statistics.first.cycle_week).to eq 18
      expect(provider_statistics.first.recruitment_cycle_year).to eq 2024
      expect(provider_statistics.first.number_of_candidates_submitted_to_date).to eq 100
      expect(provider_statistics.first.number_of_candidates_submitted_to_same_date_previous_cycle).to eq 200
      expect(provider_statistics.first.number_of_candidates_submitted_to_date_as_proportion_of_last_cycle).to eq 0.5
      expect(provider_statistics.first.number_of_candidates_with_offers_to_date).to eq 10
      expect(provider_statistics.first.number_of_candidates_with_offers_to_same_date_previous_cycle).to eq 5
      expect(provider_statistics.first.number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle).to eq 2
      expect(provider_statistics.first.number_of_candidates_accepted_to_date).to eq 1
      expect(provider_statistics.first.number_of_candidates_accepted_to_same_date_previous_cycle).to eq 10
      expect(provider_statistics.first.number_of_candidates_accepted_to_date_as_proportion_of_last_cycle).to eq 0.1
      expect(provider_statistics.first.number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date).to eq 12
      expect(provider_statistics.first.number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle).to eq 12
      expect(provider_statistics.first.number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle).to eq 0
      expect(provider_statistics.first.number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date).to eq 12
      expect(provider_statistics.first.number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle).to eq 12
      expect(provider_statistics.first.number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle).to eq 0
      expect(provider_statistics.first.number_of_candidates_who_had_an_inactive_application_this_cycle_to_date).to eq 12
      expect(provider_statistics.first.number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates).to eq 12
      expect(provider_statistics.first.number_of_candidates_submitted_to_date).to be 100
    end
  end

  describe described_class::Result do
    let(:result) { described_class.new({ provider_id: 123, nonprovider_filter: 'Primary' }) }

    describe 'attr_readers' do
      it 'has attr_reader for nonprovider_filter' do
        expect(result).to respond_to(:nonprovider_filter)
      end

      it 'has no attr_reader for nonprovider_filter_category' do
        expect(result).to respond_to(:nonprovider_filter_category)
      end
    end

    describe '#attributes' do
      it 'returns the correct #attributes' do
        expect(result.attributes).to eq({ 'provider_id' => 123, 'nonprovider_filter' => 'Primary' })
      end
    end
  end
end
