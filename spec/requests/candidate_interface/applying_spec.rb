require 'rails_helper'

RSpec.describe 'GET /candidate/apply', type: :request do
  include FindAPIHelper
  include TestHelpers::BasicAuthHelper

  before { require_and_config_basic_auth }

  describe 'authentication' do
    before { stub_find_api_course_200('ABC', 'X130', 'Biology') }

    it 'is protected by basic auth' do
      get '/candidate/apply?providerCode=ABC&courseCode=X130'
      expect(response).to have_http_status 401
    end

    context 'when the DISABLE_BASIC_AUTH_FOR_LANDING_PAGE env var is "true"' do
      it 'is not protected by basic auth' do
        ClimateControl.modify DISABLE_BASIC_AUTH_FOR_LANDING_PAGE: 'true' do
          get '/candidate/apply?providerCode=ABC&courseCode=X130'
          expect(response).to have_http_status 200
        end
      end
    end
  end
end
