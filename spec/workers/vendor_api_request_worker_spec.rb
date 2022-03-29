require 'rails_helper'

RSpec.describe VendorAPIRequestWorker do
  let(:stringified_time) { Time.zone.now.to_s }

  describe '#perform' do
    it 'creates a VendorAPIRequest record' do
      expect {
        described_class.new.perform({}, {}.to_json, 401, stringified_time)
      }.to change(VendorAPIRequest, :count).by(1)
    end

    it 'detects the provider making the request from the authorization header' do
      provider = create(:provider)
      unhashed_token, hashed_token = Devise.token_generator.generate(VendorAPIToken, :hashed_token)
      create(:vendor_api_token, hashed_token: hashed_token, provider_id: provider.id)

      headers = { 'HTTP_AUTHORIZATION' => "Bearer #{unhashed_token}" }
      described_class.new.perform({ 'headers' => headers }, {}.to_json, 500, stringified_time)

      expect(VendorAPIRequest.find_by(provider_id: provider.id)).not_to be_nil
    end
  end

  it 'accepts headers and body in response_data' do
    described_class.new.perform(
      { 'path' => '/api/v1/foo' },
      { 'headers' => { 'this' => 'that' }, 'body' => { 'that' => 'this' }.to_json },
      500,
      stringified_time,
    )

    vendor_api_request = VendorAPIRequest.find_by(request_path: '/api/v1/foo')

    expect(vendor_api_request.response_headers).to eq({ 'this' => 'that' })
    expect(vendor_api_request.response_body).to eq({ 'that' => 'this' })
  end

  it 'saves the request method on the vendor api request' do
    described_class.new.perform({ 'headers' => {}, 'path' => '/api/v1/bar', 'method' => 'GET' }, {}.to_json, 500, stringified_time)

    expect(VendorAPIRequest.find_by(request_path: '/api/v1/bar').request_method).to eq('GET')
  end

  it 'saves the created at timestamp on the vendor api request' do
    described_class.new.perform({ 'headers' => {}, 'path' => '/api/v1/bar', 'method' => 'GET' }, {}.to_json, 500, stringified_time)
    expect(VendorAPIRequest.find_by(request_path: '/api/v1/bar').created_at.to_s).to eq(stringified_time)
  end

  it 'saves params from GET requests' do
    described_class.new.perform({
      'params' => { 'foo' => 'meh' },
      'path' => '/api/v1/bar',
      'method' => 'GET',
    }, {}.to_json, 500, stringified_time)

    expect(VendorAPIRequest.find_by(request_path: '/api/v1/bar').request_body).to eq('foo' => 'meh')
  end

  it 'saves request data from POST requests' do
    described_class.new.perform({
      'body' => { 'foo' => 'meh' }.to_json,
      'path' => '/api/v1/bar',
      'method' => 'POST',
    }, {}.to_json, 500, stringified_time)

    expect(VendorAPIRequest.find_by(request_path: '/api/v1/bar').request_body).to eq('foo' => 'meh')
  end

  it 'records when POST data is not valid JSON' do
    described_class.new.perform({
      'body' => 'This is not JSON',
      'path' => '/api/v1/bar',
      'method' => 'POST',
    }, {}.to_json, 500, stringified_time)

    expect(VendorAPIRequest.find_by(request_path: '/api/v1/bar').request_body).to eq('error' => 'request data did not contain valid JSON')
  end

  it 'handles empty POST data' do
    described_class.new.perform({
      'body' => '',
      'path' => '/api/v1/bar',
      'method' => 'POST',
    }, {}.to_json, 500, stringified_time)

    expect(VendorAPIRequest.find_by(request_path: '/api/v1/bar').request_body).to be_nil
  end
end
