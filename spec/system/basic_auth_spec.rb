require 'rails_helper'

RSpec.describe 'Require basic authentication', type: :request do
  include TestHelpers::BasicAuthHelper

  context 'candidate_interface' do
    it 'requests when basic auth is disabled are let through' do
      ClimateControl.modify BASIC_AUTH_ENABLED: nil do
        get candidate_interface_create_account_or_sign_in_url
      end

      expect(response).to have_http_status(:ok)
    end

    it 'requests without basic auth get 401' do
      ClimateControl.modify BASIC_AUTH_ENABLED: '1', BASIC_AUTH_USERNAME: 'foo', BASIC_AUTH_PASSWORD: 'bar' do
        get candidate_interface_create_account_or_sign_in_url
      end

      expect(response).to have_http_status(:unauthorized)
    end

    it 'requests with invalid basic auth get 401' do
      ClimateControl.modify BASIC_AUTH_ENABLED: '1', BASIC_AUTH_USERNAME: 'foo', BASIC_AUTH_PASSWORD: 'bar' do
        get candidate_interface_create_account_or_sign_in_url, headers: basic_auth_headers('wrong', 'auth')
      end

      expect(response).to have_http_status(:unauthorized)
    end

    it 'requests with valid basic auth get 200' do
      ClimateControl.modify BASIC_AUTH_ENABLED: '1', BASIC_AUTH_USERNAME: 'foo', BASIC_AUTH_PASSWORD: 'bar' do
        get candidate_interface_create_account_or_sign_in_url, headers: basic_auth_headers('foo', 'bar')
      end

      expect(response).to have_http_status(:ok)
    end
  end
end
