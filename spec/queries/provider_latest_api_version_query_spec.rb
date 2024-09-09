require 'rails_helper'

RSpec.describe ProviderLatestAPIVersionQuery do
  subject(:query) do
    described_class.new(provider_id: provider.id).call
  end

  let(:vendor_api_requests) do
    [
      create(:vendor_api_request, request_path: '/api/v1.1/applications'),
      create(:vendor_api_request, request_path: '/api/v1.5/applications'),
    ]
  end
  let!(:provider) { create(:provider, vendor_api_requests:) }

  context 'when there are multiple api versions' do
    it 'does not return the provider' do
      expect(query).to eq('1.5')
    end
  end

  context 'when a provider has no api requests' do
    let(:vendor_api_requests) { [] }

    it 'only returns one row per provider' do
      expect(query).to be_nil
    end
  end
end
