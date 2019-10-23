require 'rails_helper'

RSpec.describe 'Require basic authentication', type: :request do
  include TestHelpers::BasicAuthHelper

  before do
    stub_const('FEATURES', FEATURES.merge(basic_auth: { enabled: true, username: 'basic', password: 'auth' }))
  end

  context 'candidate_interface' do
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
end
