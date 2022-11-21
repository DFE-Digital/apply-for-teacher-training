require 'rails_helper'

RSpec.describe 'API Docs - GET /api-docs/spec*.yml' do
  describe 'GET /api-docs/spec.yml' do
    it 'returns the most recent spec in YAML format' do
      get '/api-docs/spec.yml'

      expect(response).to have_http_status(:ok)
      expect(response.body).to match('openapi: 3.0.0')
      expect(response.body).to match(/version: v1.2$/)
    end
  end

  describe 'GET /api-docs/spec-draft.yml' do
    context 'when the draft feature flag is active' do
      around do |example|
        FeatureFlag.activate(:draft_vendor_api_specification) { example.run }
      end

      it 'returns the draft spec in YAML format' do
        get '/api-docs/spec-draft.yml'

        expect(response).to have_http_status(:ok)
        expect(response.body).to match('openapi: 3.0.0')
        expect(response.body).to match(/version: v1.3$/)
      end
    end

    context 'when the draft feature flag is not active' do
      around do |example|
        FeatureFlag.deactivate(:draft_vendor_api_specification) { example.run }
      end

      it 'redirects to the most recent spec' do
        get '/api-docs/spec-draft.yml'

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to('/api-docs/spec.yml')
      end
    end
  end

  %w[1.0 1.1 1.2].each do |version|
    describe "GET /api-docs/spec-#{version}.yml" do
      it "returns the #{version} spec in YAML format" do
        get "/api-docs/spec-#{version}.yml"

        expect(response).to have_http_status(:ok)
        expect(response.body).to match('openapi: 3.0.0')
        expect(response.body).to match(/version: v#{version}$/)
      end
    end
  end
end
