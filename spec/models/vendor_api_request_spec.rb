require 'rails_helper'

RSpec.describe VendorAPIRequest, type: :model do
  describe '.list_of_distinct_errors_with_count' do
    it 'returns a list of grouped errors' do
      create_list(:vendor_api_request, 2, :with_validation_error)

      expect(described_class.list_of_distinct_errors_with_count).to contain_exactly(
        [
          [
            '/api/v1/applications',
            'ValidationError',
            'Some error message',
          ],
          2,
        ],
      )
    end

    it 'sorts the list of errors by occurrence' do
      create(:vendor_api_request, :with_validation_error, request_path: '/api/v1/applications/21629/reject')
      create_list(:vendor_api_request, 2, :with_validation_error)

      expect(described_class.list_of_distinct_errors_with_count).to contain_exactly(
        [
          [
            '/api/v1/applications',
            'ValidationError',
            'Some error message',
          ],
          2,
        ],
        [
          [
            '/api/v1/applications/21629/reject',
            'ValidationError',
            'Some error message',
          ],
          1,
        ],
      )
    end

    it 'extracts separate errors from the same request' do
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
      create(:vendor_api_request, :with_validation_error, response_body: response_body)

      expect(described_class.list_of_distinct_errors_with_count).to contain_exactly(
        [
          [
            '/api/v1/applications',
            'ValidationError',
            'Some error message',
          ],
          1,
        ],
        [
          [
            '/api/v1/applications',
            'ParameterMissing',
            'Some other error message',
          ],
          1,
        ],
      )
    end

    it 'does not return successful requests' do
      create(:vendor_api_request)

      expect(described_class.list_of_distinct_errors_with_count).to be_empty
    end
  end

  describe '.search_validation_errors' do
    it 'does not return successful requests' do
      create(:vendor_api_request)

      expect(described_class.search_validation_errors({})).to be_empty
    end

    it 'returns all validation error requests with empty params' do
      request = create(:vendor_api_request, :with_validation_error)

      expect(described_class.search_validation_errors({})).to contain_exactly(request)
    end

    it 'returns validation errors scoped to request path' do
      request = create(:vendor_api_request, :with_validation_error)
      params = { request_path: request.request_path }

      expect(described_class.search_validation_errors(params)).to contain_exactly(request)
    end

    it 'returns validation errors scoped to provider' do
      request = create(:vendor_api_request, :with_validation_error)
      params = { provider_id: request.provider_id }

      expect(described_class.search_validation_errors(params)).to contain_exactly(request)
    end

    it 'returns validation errors scoped to request id' do
      request = create(:vendor_api_request, :with_validation_error)
      params = { id: request.id }

      expect(described_class.search_validation_errors(params)).to contain_exactly(request)
    end

    it 'returns validation errors scoped to error name' do
      request = create(:vendor_api_request, :with_validation_error)
      params = { attribute: 'ValidationError' }

      expect(described_class.search_validation_errors(params)).to contain_exactly(request)
    end

    it 'returns validation errors scoped to error name with multiple errors in same request' do
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
      request = create(:vendor_api_request, :with_validation_error, response_body: response_body)

      params = { attribute: 'ParameterMissing' }

      expect(described_class.search_validation_errors(params)).to contain_exactly(request)
    end

    it 'returns validation errors scoped to multiple parameters' do
      request = create(:vendor_api_request, :with_validation_error)

      create(:vendor_api_request, :with_validation_error, request_path: '/api/v1/applications/21629/reject', provider: request.provider)

      params = { provider: request.provider, request_path: '/api/v1/applications' }

      expect(described_class.search_validation_errors(params)).to contain_exactly(request)
    end

    it 'does not return requests if none found' do
      expect(described_class.search_validation_errors({})).to be_empty
    end
  end
end
