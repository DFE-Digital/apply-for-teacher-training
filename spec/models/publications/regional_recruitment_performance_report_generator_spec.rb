require 'rails_helper'

RSpec.describe Publications::RegionalRecruitmentPerformanceReportGenerator do
  include DfE::Bigquery::TestHelper

  subject(:generator) { described_class.new(cycle_week:, region:) }

  before do
    stub_bigquery_regional_provider_metrics_request(
      rows: [[
        { name: 'nonregion_filter', type: 'STRING', value: 'Primary' },
        { name: 'nonregion_filter_category', type: 'STRING', value: nil },
        { name: 'cycle_week', type: 'INTEGER', value: cycle_week.to_s },
        { name: 'region_filter', type: 'STRING', value: nil },
      ]],
    )
  end

  let(:cycle_week) { 11 }
  let(:region) { 'London' }
  let(:generation_date) { Time.zone.today }
  let(:attributes) do
    [{ 'nonregion_filter' => 'Primary',
       'nonregion_filter_category' => nil,
       'cycle_week' => cycle_week,
       'recruitment_cycle_year' => nil,
       'region_filter' => nil,
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

  it 'returns data' do
    expect(generator.data).to eq(attributes)
  end

  describe '#call' do
    context 'when cycle_week is 12' do
      it 'creates a new report' do
        expect { generator.call }.to change(Publications::RegionalRecruitmentPerformanceReport, :count).by(1)
      end

      it 'stores the correct data in the model' do
        generator.call

        model = Publications::RegionalRecruitmentPerformanceReport.last

        expect(model).to have_attributes({
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

        model = Publications::RegionalRecruitmentPerformanceReport.last

        expect(model).to have_attributes({
          'publication_date' => generation_date,
          'generation_date' => generation_date,
          'cycle_week' => 15,
          'statistics' => attributes,
        })
      end
    end

    context 'when reports already exist' do
      subject(:generator) { described_class.new(cycle_week:, region:, recruitment_cycle_year: 2026) }

      let!(:two_weeks_ago) { create(:regional_recruitment_performance_report, region: :london, recruitment_cycle_year: 2026, cycle_week: 9) }
      let!(:previous_week) { create(:regional_recruitment_performance_report, region: :london, recruitment_cycle_year: 2026, cycle_week: 10) }
      let!(:previous_cycle) { create(:regional_recruitment_performance_report, region: :london, recruitment_cycle_year: 2025, cycle_week: 52) }
      let!(:other_region) { create(:regional_recruitment_performance_report, region: :north_east, recruitment_cycle_year: 2026, cycle_week: 9) }

      it 'keeps the new report, the previous week, other cycles and other regions' do
        generator.call

        current = Publications::RegionalRecruitmentPerformanceReport.order(:id).last
        expect(Publications::RegionalRecruitmentPerformanceReport.all).to contain_exactly(current, previous_week, previous_cycle, other_region)
      end

      it 'deletes older weeks and duplicates of the same week for the region in the cycle' do
        generator.call

        expect(Publications::RegionalRecruitmentPerformanceReport.where(id: [two_weeks_ago.id])).to be_empty
      end
    end

    context 'when setting a future generation date' do
      subject(:generator) { described_class.new(cycle_week:, generation_date:, region:) }

      let(:generation_date) { 1.week.from_now.to_date }

      it 'stores the correct data in the model' do
        generator.call

        model = Publications::RegionalRecruitmentPerformanceReport.last

        expect(model).to have_attributes({
          'publication_date' => generation_date,
          'generation_date' => generation_date,
          'cycle_week' => cycle_week,
          'statistics' => attributes,
        })
      end
    end
  end
end
