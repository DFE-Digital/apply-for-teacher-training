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

  it 'accepts headers and body in response_data' do
    described_class.new.perform(
      { 'headers' => {}, 'path' => '/api/v1/foo' },
      { 'headers' => { 'this' => 'that' }, 'body' => { 'that' => 'this' }.to_json },
      500,
      Time.zone.now,
    )

    vendor_api_request = VendorAPIRequest.find_by(request_path: '/api/v1/foo')

    expect(vendor_api_request.response_headers).to eq({ 'this' => 'that' })
    expect(vendor_api_request.response_body).to eq({ 'that' => 'this' })
  end

  it 'saves the request method on the vendor api request' do
    described_class.new.perform({ 'headers' => {}, 'path' => '/api/v1/bar', 'method' => 'GET' }, {}.to_json, 500, Time.zone.now)

    expect(VendorAPIRequest.find_by(request_path: '/api/v1/bar').request_method).to eq('GET')
  end
end
