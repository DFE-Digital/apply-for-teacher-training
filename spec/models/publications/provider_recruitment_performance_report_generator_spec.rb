require 'rails_helper'

RSpec.describe Publications::ProviderRecruitmentPerformanceReportGenerator do
  include DfE::Bigquery::TestHelper

  subject(:generator) { described_class.new(provider_id:, cycle_week:) }

  let(:cycle_week) { 12 }
  let(:provider_id) { create(:provider).id }
  let(:generation_date) { Time.zone.today }

  describe 'when a normal response is received', seed_timetables do
    before do
      stub_bigquery_application_metrics_by_provider_request(
        rows: [[
          { name: 'nonprovider_filter', type: 'STRING', value: 'Primary' },
          { name: 'nonprovider_filter_category', type: 'STRING', value: nil },
          { name: 'cycle_week', type: 'INTEGER', value: cycle_week.to_s },
          { name: 'id', type: 'INTEGER', value: provider_id.to_s },
        ]],
      )
    end

    # BigQuery returns symbols, #attributes returns strings
    # BigQuery returns :id, for 'provider.id'
    let(:attributes) do
      [
        {
          'nonprovider_filter' => 'Primary',
          'nonprovider_filter_category' => nil,
          'cycle_week' => cycle_week,
          'recruitment_cycle_year' => nil,
          'provider_id' => provider_id,
          'number_of_candidates_submitted_to_date' => nil,
          'number_of_candidates_submitted_to_same_date_previous_cycle' => nil,
          'number_of_candidates_submitted_to_date_as_proportion_of_last_cycle' => nil,
          'number_of_candidates_with_offers_to_date' => nil,
          'number_of_candidates_with_offers_to_same_date_previous_cycle' => nil,
          'number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle' => nil,
          'offer_rate_to_date' => nil,
          'offer_rate_to_same_date_previous_cycle' => nil,
          'number_of_candidates_accepted_to_date' => nil,
          'number_of_candidates_accepted_to_same_date_previous_cycle' => nil,
          'number_of_candidates_accepted_to_date_as_proportion_of_last_cycle' => nil,
          'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date' => nil,
          'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle' => nil,
          'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle' => nil,
          'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date' => nil,
          'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle' => nil,
          'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle' => nil,
          'number_of_candidates_who_had_an_inactive_application_this_cycle_to_date' => nil,
          'number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates' => nil,
          'number_of_candidates_who_had_an_inactive_application_last_cycle_to_date_as_proportion_of_submitted_candidates_last_cycle' => nil,
        },
      ]
    end

    it 'returns a hash of the response data' do
      expect(generator.data).to eq(attributes)
    end

    describe '#call' do
      context 'when cycle_week is 12' do
        it 'creates a new report' do
          expect { generator.call }.to change(Publications::ProviderRecruitmentPerformanceReport, :count).by(1)
        end

        it 'stores the correct data in the model' do
          generator.call
          model = Publications::ProviderRecruitmentPerformanceReport.last

          expect(model).to have_attributes({
            'provider_id' => provider_id,
            'publication_date' => Time.zone.today,
            'generation_date' => Time.zone.today,
            'cycle_week' => cycle_week,
            'statistics' => attributes,
          })
        end
      end

      context 'when cycle_week is 15' do
        let(:cycle_week) { 15 }

        it 'stores the correct data in the model' do
          generator.call

          model = Publications::ProviderRecruitmentPerformanceReport.last

          expect(model).to have_attributes({
            'provider_id' => provider_id,
            'publication_date' => generation_date,
            'generation_date' => generation_date,
            'cycle_week' => 15,
            'statistics' => attributes,
          })
        end
      end

      context 'when setting a future generation date' do
        subject(:generator) { described_class.new(provider_id:, cycle_week:, generation_date:) }

        let(:generation_date) { 1.week.from_now.to_date }

        it 'stores the correct data in the model' do
          generator.call

          model = Publications::ProviderRecruitmentPerformanceReport.last

          expect(model).to have_attributes({
            'provider_id' => provider_id,
            'publication_date' => generation_date,
            'generation_date' => generation_date,
            'cycle_week' => cycle_week,
            'statistics' => attributes,
          })
        end
      end
    end

    describe 'when an empty response is received from Bigquery' do
      before do
        stub_bigquery_application_metrics_by_provider_request(rows: [])
      end

      let(:attributes) { [] }

      it 'returns an empty array from the response' do
        expect(generator.data).to eq(attributes)
      end

      it 'does not create a report if the data is empty' do
        expect { generator.call }.not_to change(Publications::ProviderRecruitmentPerformanceReport, :count)
      end
    end
  end
end
