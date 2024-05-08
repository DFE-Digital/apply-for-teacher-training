require 'rails_helper'

RSpec.describe Publications::ProviderRecruitmentPerformanceReportGenerator do
  include DfE::Bigquery::TestHelper
  subject(:generator) { described_class.new(provider_id:, cycle_week:) }

  before do
    @stubbed_response = application_metrics_by_provider_results(
      {
        nonprovider_filter: 'Primary',
        nonprovider_filter_category: nil,
        cycle_week: nil,
        recruitment_cycle_year: nil,
        id: provider_id,
      },
    )

    stub_bigquery_application_metrics_by_provider_request(@stubbed_response)
  end

  let(:cycle_week) { 12 }
  let(:provider_id) { create(:provider).id }
  let(:generation_date) { Time.zone.today }
  # BigQuery returns symbols, #attributes returns strings
  # BigQuery returns :id, for 'provider.id'
  let(:attributes) do
    @stubbed_response.first[:provider_id] = @stubbed_response.first.delete(:id)
    @stubbed_response.first.stringify_keys!
    @stubbed_response
  end

  it 'returns data' do
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
end
