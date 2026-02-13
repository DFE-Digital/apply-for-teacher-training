require 'rails_helper'

RSpec.describe Publications::RegionalEdiReportGenerator do
  include DfE::Bigquery::TestHelper

  subject(:generator) { described_class.new(cycle_week:, region:, category:) }

  let(:cycle_week) { 11 }
  let(:region) { 'London' }
  let(:category) { 'sex' }
  let(:generation_date) { Time.zone.today }
  let(:regional_attributes) do
    [{ 'nonregion_filter' => 'Prefer not to say',
       'nonregion_filter_category' => category,
       'cycle_week' => cycle_week,
       'recruitment_cycle_year' => nil,
       'region_filter' => region,
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
       'number_of_candidates_who_had_an_inactive_application_last_cycle_to_date_as_proportion_of_submitted_candidates_last_cycle' => nil }]
  end

  let(:national_attributes) do
    [{ 'nonprovider_filter' => 'Prefer not to say',
       'nonprovider_filter_category' => category,
       'cycle_week' => cycle_week,
       'recruitment_cycle_year' => nil,
       'provider_id' => nil,
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
       'number_of_candidates_who_had_an_inactive_application_last_cycle_to_date_as_proportion_of_submitted_candidates_last_cycle' => nil }]
  end

  context 'when region is not national' do
    before do
      stub_bigquery_regional_edi_request(
        rows: [[
          { name: 'nonregion_filter', type: 'STRING', value: 'Prefer not to say' },
          { name: 'nonregion_filter_category', type: 'STRING', value: category },
          { name: 'cycle_week', type: 'INTEGER', value: cycle_week.to_s },
          { name: 'region_filter', type: 'STRING', value: region },
        ]],
      )
    end

    it 'returns regional data' do
      expect(generator.data).to eq(regional_attributes)
    end
  end

  context 'when region is national' do
    let(:region) { 'All of England' }

    before do
      stub_bigquery_national_edi_request(
        rows: [[
          { name: 'nonprovider_filter', type: 'STRING', value: 'Prefer not to say' },
          { name: 'nonprovider_filter_category', type: 'STRING', value: category },
          { name: 'cycle_week', type: 'INTEGER', value: cycle_week.to_s },
        ]],
      )
    end

    it 'returns national data' do
      expect(generator.data).to eq(national_attributes)
    end
  end

  describe '#call' do
    context 'when region is not national' do
      before do
        stub_bigquery_regional_edi_request(
          rows: [[
            { name: 'nonregion_filter', type: 'STRING', value: 'Prefer not to say' },
            { name: 'nonregion_filter_category', type: 'STRING', value: category },
            { name: 'cycle_week', type: 'INTEGER', value: cycle_week.to_s },
            { name: 'region_filter', type: 'STRING', value: region },
          ]],
        )
      end

      context 'when cycle_week is 12' do
        it 'creates a new report' do
          expect { generator.call }.to change(Publications::RegionalEdiReport, :count).by(1)
        end

        it 'stores the correct data in the model' do
          generator.call

          model = Publications::RegionalEdiReport.last

          expect(model).to have_attributes({
            'publication_date' => Time.zone.today,
            'generation_date' => Time.zone.today,
            'cycle_week' => cycle_week,
            'category' => category,
            'statistics' => regional_attributes,
          })
        end
      end

      context 'when cycle_week is 15' do
        let(:cycle_week) { 15 }

        it 'stores the correct data in the model' do
          generator.call

          model = Publications::RegionalEdiReport.last

          expect(model).to have_attributes({
            'publication_date' => generation_date,
            'generation_date' => generation_date,
            'cycle_week' => 15,
            'category' => category,
            'statistics' => regional_attributes,
          })
        end
      end

      context 'when setting a future generation date' do
        subject(:generator) { described_class.new(cycle_week:, generation_date:, region:, category:) }

        let(:generation_date) { 1.week.from_now.to_date }

        it 'stores the correct data in the model' do
          generator.call

          model = Publications::RegionalEdiReport.last

          expect(model).to have_attributes({
            'publication_date' => generation_date,
            'generation_date' => generation_date,
            'category' => category,
            'cycle_week' => cycle_week,
            'statistics' => regional_attributes,
          })
        end
      end
    end

    context 'when region is national' do
      before do
        stub_bigquery_national_edi_request(
          rows: [[
            { name: 'nonprovider_filter', type: 'STRING', value: 'Prefer not to say' },
            { name: 'nonprovider_filter_category', type: 'STRING', value: category },
            { name: 'cycle_week', type: 'INTEGER', value: cycle_week.to_s },
          ]],
        )
      end

      let(:region) { 'All of England' }

      context 'when cycle_week is 12' do
        it 'creates a new report' do
          expect { generator.call }.to change(Publications::RegionalEdiReport, :count).by(1)
        end

        it 'stores the correct data in the model' do
          generator.call

          model = Publications::RegionalEdiReport.last

          expect(model).to have_attributes({
            'publication_date' => Time.zone.today,
            'generation_date' => Time.zone.today,
            'cycle_week' => cycle_week,
            'category' => category,
            'statistics' => national_attributes,
          })
        end
      end

      context 'when cycle_week is 15' do
        let(:cycle_week) { 15 }

        it 'stores the correct data in the model' do
          generator.call

          model = Publications::RegionalEdiReport.last

          expect(model).to have_attributes({
            'publication_date' => generation_date,
            'generation_date' => generation_date,
            'cycle_week' => 15,
            'category' => category,
            'statistics' => national_attributes,
          })
        end
      end

      context 'when setting a future generation date' do
        subject(:generator) { described_class.new(cycle_week:, generation_date:, region:, category:) }

        let(:generation_date) { 1.week.from_now.to_date }

        it 'stores the correct data in the model' do
          generator.call

          model = Publications::RegionalEdiReport.last

          expect(model).to have_attributes({
            'publication_date' => generation_date,
            'generation_date' => generation_date,
            'category' => category,
            'cycle_week' => cycle_week,
            'statistics' => national_attributes,
          })
        end
      end
    end
  end
end
