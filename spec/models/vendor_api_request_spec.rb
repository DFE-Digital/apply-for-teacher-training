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
end
