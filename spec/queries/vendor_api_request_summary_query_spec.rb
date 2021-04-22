require 'rails_helper'

RSpec.describe VendorAPIRequestSummaryQuery do
  describe '#call' do
    it 'returns an empty result' do
      expect(described_class.new.call).to eq([])
    end

    it 'returns data for each time period' do
      create(:vendor_api_request, :with_validation_error, created_at: 2.days.ago)
      create(:vendor_api_request, :with_validation_error, created_at: 10.days.ago)
      old_error = create(:vendor_api_request, :with_validation_error, created_at: 60.days.ago)
      create(:vendor_api_request, :with_validation_error, created_at: 60.days.ago, provider: old_error.provider)

      expect(described_class.new.call).to eq([
        {
          'attribute' => 'ValidationError',
          'request_path' => '/api/v1/applications',
          'incidents_all_time' => 4,
          'incidents_last_month' => 2,
          'incidents_last_week' => 1,
          'unique_providers_all_time' => 3,
          'unique_providers_last_month' => 2,
          'unique_providers_last_week' => 1,
        },
      ])
    end

    it 'extracts separate errors from response body from the same request' do
      response_body = {
        'errors' => [
          {
            'error' => 'ValidationError',
            'message' => 'Some error message',
          },
          {
            'error' => 'ParameterMissing',
            'message' => 'Some other error message',
          },
        ],
      }
      create(:vendor_api_request, :with_validation_error, response_body: response_body, created_at: 2.days.ago)

      expect(described_class.new(described_class::ALL_TIME).call).to eq([
        {
          'request_path' => '/api/v1/applications',
          'attribute' => 'ParameterMissing',
          'incidents_last_week' => 1,
          'unique_providers_last_week' => 1,
          'incidents_last_month' => 1,
          'unique_providers_last_month' => 1,
          'incidents_all_time' => 1,
          'unique_providers_all_time' => 1,
        },
        {
          'request_path' => '/api/v1/applications',
          'attribute' => 'ValidationError',
          'incidents_last_week' => 1,
          'unique_providers_last_week' => 1,
          'incidents_last_month' => 1,
          'unique_providers_last_month' => 1,
          'incidents_all_time' => 1,
          'unique_providers_all_time' => 1,
        },
      ])
    end

    context 'when sorting' do
      it "returns results sorted by 'All time'" do
        create(:vendor_api_request, :with_validation_error, request_path: '/api/v1/applications', created_at: 2.days.ago)
        create(:vendor_api_request, :with_validation_error, request_method: 'POST', request_path: '/api/v1/applications/22/offer', created_at: 6.days.ago)
        create(:vendor_api_request, :with_validation_error, request_path: '/api/v1/applications/22', created_at: 50.days.ago)
        create(:vendor_api_request, :with_validation_error, request_path: '/api/v1/applications/22', created_at: 60.days.ago)

        expect(described_class.new(described_class::ALL_TIME).call).to eq([
          {
            'request_path' => '/api/v1/applications/22',
            'attribute' => 'ValidationError',
            'incidents_last_week' => 0,
            'unique_providers_last_week' => 0,
            'incidents_last_month' => 0,
            'unique_providers_last_month' => 0,
            'incidents_all_time' => 2,
            'unique_providers_all_time' => 2,
          },
          {
            'request_path' => '/api/v1/applications',
            'attribute' => 'ValidationError',
            'incidents_last_week' => 1,
            'unique_providers_last_week' => 1,
            'incidents_last_month' => 1,
            'unique_providers_last_month' => 1,
            'incidents_all_time' => 1,
            'unique_providers_all_time' => 1,
          },
          {
            'request_path' => '/api/v1/applications/22/offer',
            'attribute' => 'ValidationError',
            'incidents_last_week' => 1,
            'unique_providers_last_week' => 1,
            'incidents_last_month' => 1,
            'unique_providers_last_month' => 1,
            'incidents_all_time' => 1,
            'unique_providers_all_time' => 1,
          },
        ])
      end

      it "returns results sorted by 'Last week'" do
        create(:vendor_api_request, :with_validation_error, request_path: '/api/v1/applications', created_at: 2.days.ago)
        create(:vendor_api_request, :with_validation_error, request_path: '/api/v1/applications/22/offer', created_at: 6.days.ago)
        create(:vendor_api_request, :with_validation_error, request_path: '/api/v1/applications/22/offer', created_at: 5.days.ago)
        create(:vendor_api_request, :with_validation_error, request_path: '/api/v1/applications', created_at: 10.days.ago)

        expect(described_class.new(described_class::LAST_WEEK).call).to eq([
          {
            'request_path' => '/api/v1/applications/22/offer',
            'attribute' => 'ValidationError',
            'incidents_last_week' => 2,
            'unique_providers_last_week' => 2,
            'incidents_last_month' => 2,
            'unique_providers_last_month' => 2,
            'incidents_all_time' => 2,
            'unique_providers_all_time' => 2,
          },
          {
            'request_path' => '/api/v1/applications',
            'attribute' => 'ValidationError',
            'incidents_last_week' => 1,
            'unique_providers_last_week' => 1,
            'incidents_last_month' => 2,
            'unique_providers_last_month' => 2,
            'incidents_all_time' => 2,
            'unique_providers_all_time' => 2,
          },
        ])
      end

      it "returns resulted sorted by 'Last month'" do
        create(:vendor_api_request, :with_validation_error, request_path: '/api/v1/applications', created_at: 2.days.ago)
        create(:vendor_api_request, :with_validation_error, request_path: '/api/v1/applications/22/offer', created_at: 6.days.ago)
        create(:vendor_api_request, :with_validation_error, request_path: '/api/v1/applications', created_at: 10.days.ago)

        expect(described_class.new(described_class::LAST_MONTH).call).to eq([
          {
            'request_path' => '/api/v1/applications',
            'attribute' => 'ValidationError',
            'incidents_last_week' => 1,
            'unique_providers_last_week' => 1,
            'incidents_last_month' => 2,
            'unique_providers_last_month' => 2,
            'incidents_all_time' => 2,
            'unique_providers_all_time' => 2,
          },
          {
            'request_path' => '/api/v1/applications/22/offer',
            'attribute' => 'ValidationError',
            'incidents_last_week' => 1,
            'unique_providers_last_week' => 1,
            'incidents_last_month' => 1,
            'unique_providers_last_month' => 1,
            'incidents_all_time' => 1,
            'unique_providers_all_time' => 1,
          },
        ])
      end
    end
  end
end
