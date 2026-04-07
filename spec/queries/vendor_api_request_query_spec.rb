require 'rails_helper'

RSpec.describe VendorAPIRequestQuery do
  describe '.call' do
    subject(:call) { described_class.call(params:) }

    let(:params) { {} }

    context 'when no params are given' do
      let(:older_api_request) { create(:vendor_api_request) }
      let(:vendor_api_requests) { create_list(:vendor_api_request, 10) }

      before do
        stub_const('VendorAPIRequestQuery::LIMIT', 10)
        older_api_request
        vendor_api_requests
      end

      it 'returns the latest 5000 vendor API requests' do
        recent_api_requests = VendorAPIRequest.where(id: vendor_api_requests.pluck(:id))
        results = call
        expect(results).to match_array(recent_api_requests)
        expect(results.count).to eq(10)
      end
    end

    context 'when given a provider code param' do
      let(:provider) { create(:provider, code: 'ZZZ') }
      let(:provider_api_request) { create(:vendor_api_request, provider:) }
      let(:random_api_request) { create(:vendor_api_request) }
      let(:params) { { provider_code: 'ZZZ' } }

      before do
        provider_api_request
        random_api_request
      end

      it 'returns only vendor API requests for the given provider' do
        expect(call).to contain_exactly(provider_api_request)
      end

      context 'when the provider code given does not match a provider' do
        let(:params) { { provider_code: 'XXX' } }

        it 'returns no vendor API request records' do
          expect(call).to eq(VendorAPIRequest.none.limit(5000))
        end
      end
    end

    context 'when given a request_path (:q) param' do
      let(:vendor_api_request_1) { create(:vendor_api_request, request_path: 'api/records/ba') }
      let(:vendor_api_request_2) { create(:vendor_api_request, request_path: 'api/records/foo') }
      let(:vendor_api_request_3) { create(:vendor_api_request, request_path: 'api/something') }
      let(:params) { { q: 'api/records' } }

      it 'returns only vendor API requests matching the given request path' do
        expect(call).to contain_exactly(vendor_api_request_1, vendor_api_request_2)
      end
    end

    context 'when given a request_body (:q) param' do
      let(:vendor_api_request_1) { create(:vendor_api_request, request_body: { 'data' => [1, 2, 3] }) }
      let(:vendor_api_request_2) { create(:vendor_api_request, request_body: { 'data' => %w[a b c] }) }
      let(:vendor_api_request_3) { create(:vendor_api_request, request_body: { 'errors' => [{ 'error' => 'Not found' }] }) }
      let(:params) { { q: 'data' } }

      it 'returns only vendor API requests matching the given request body' do
        expect(call).to contain_exactly(vendor_api_request_1, vendor_api_request_2)
      end
    end

    context 'when given a response_body (:q) param' do
      let(:vendor_api_request_1) { create(:vendor_api_request, response_body: { 'data' => [1, 2, 3] }) }
      let(:vendor_api_request_2) { create(:vendor_api_request, response_body: { 'data' => %w[a b c] }) }
      let(:vendor_api_request_3) { create(:vendor_api_request, response_body: { 'errors' => [{ 'error' => 'Not found' }] }) }
      let(:params) { { q: 'data' } }

      it 'returns only vendor API requests matching the given response body' do
        expect(call).to contain_exactly(vendor_api_request_1, vendor_api_request_2)
      end
    end

    context 'when given a status code param' do
      let(:vendor_api_request_1) { create(:vendor_api_request, status_code: 200) }
      let(:vendor_api_request_2) { create(:vendor_api_request, status_code: 500) }
      let(:vendor_api_request_3) { create(:vendor_api_request, status_code: 301) }
      let(:params) { { status_code: [200, 500] } }

      it 'returns only vendor API requests matching the given status codes' do
        expect(call).to contain_exactly(vendor_api_request_1, vendor_api_request_2)
      end
    end

    context 'when given a request_method param' do
      let(:vendor_api_request_1) { create(:vendor_api_request, request_method: 'GET') }
      let(:vendor_api_request_2) { create(:vendor_api_request, request_method: 'POST') }
      let(:vendor_api_request_3) { create(:vendor_api_request, request_method: 'DELETE') }
      let(:params) { { request_method: %w[GET POST] } }

      it 'returns only vendor API requests matching the given request methods' do
        expect(call).to contain_exactly(vendor_api_request_1, vendor_api_request_2)
      end
    end
  end
end
