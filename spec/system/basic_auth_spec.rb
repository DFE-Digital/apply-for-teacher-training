require 'rails_helper'

RSpec.describe 'Require basic authentication', type: :request do
  include TestHelpers::BasicAuthHelper

  context 'without the relevant environment vars' do
    before do
      stub_const(
        'BASIC_AUTH',
        BASIC_AUTH.merge(ui_auth: { enabled: true, username: nil, password: nil }),
      )
    end

    it 'candidate requests raise KeyError' do
      expect { get candidate_interface_start_url }.to raise_error(KeyError)
    end
  end

  context 'candidate_interface' do
    before { require_and_config_basic_auth }

    it 'requests without basic auth get 401' do
      get candidate_interface_start_url

      expect(response).to have_http_status(401)
    end

    it 'requests with invalid basic auth get 401' do
      get candidate_interface_start_url, headers: basic_auth_headers('wrong', 'auth')

      expect(response).to have_http_status(401)
    end

    it 'requests with valid basic auth get 200' do
      get candidate_interface_start_url, headers: basic_auth_headers('basic', 'auth')

      expect(response).to have_http_status(200)
    end
  end

  context 'support_interface' do
    before { require_and_config_basic_auth }

    it 'requests with valid basic auth get 401' do
      get support_interface_api_tokens_url, headers: basic_auth_headers('basic', 'auth')

      expect(response).to have_http_status(401)
    end

    it 'requests with valid support auth get 200' do
      headers = basic_auth_headers ENV.fetch('SUPPORT_USERNAME'), ENV.fetch('SUPPORT_PASSWORD')
      get support_interface_api_tokens_url, headers: headers

      expect(response).to have_http_status(200)
    end
  end

  context 'vendor_api' do
    before { require_and_config_basic_auth }

    it 'does not require basic auth even when elsewhere enabled' do
      unhashed_token = VendorApiToken.create_with_random_token!(provider: create(:provider))

      get '/api/v1/ping', headers: { 'Authorization' => "Bearer #{unhashed_token}" }

      expect(response).to have_http_status(200)
    end
  end
end
