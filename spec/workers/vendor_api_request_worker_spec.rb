require 'rails_helper'

RSpec.describe VendorAPIRequestWorker do
  describe '#perform' do
    it 'creates a VendorAPIRequest record' do
      expect {
        described_class.new.perform({ 'headers' => [] }, {}.to_json, 401, Time.zone.now)
      }.to change(VendorAPIRequest, :count).by(1)
    end

    it 'detects the provider making the request from the authorization header' do
      provider = create(:provider)
      unhashed_token, hashed_token = Devise.token_generator.generate(VendorAPIToken, :hashed_token)
      create(:vendor_api_token, hashed_token: hashed_token, provider_id: provider.id)

      headers = { 'HTTP_AUTHORIZATION' => "Bearer #{unhashed_token}" }
      described_class.new.perform({ 'headers' => headers }, {}.to_json, 500, Time.zone.now)

      expect(VendorAPIRequest.find_by(provider_id: provider.id)).not_to be nil
    end
  end
end
