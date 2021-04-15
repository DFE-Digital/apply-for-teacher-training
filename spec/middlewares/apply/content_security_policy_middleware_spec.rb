require 'rails_helper'

RSpec.describe Apply::ContentSecurityPolicyMiddleware, type: :request do
  let(:status) { 200 }
  let(:headers) { { 'HEADER' => 'Yeah!' } }
  let(:mock_response) { ['Hellowwworlds!'] }

  def mock_app
    main_app = lambda { |env|
      @env = env
      [status, headers, @body || mock_response]
    }

    builder = Rack::Builder.new
    builder.use Apply::ContentSecurityPolicyMiddleware
    builder.run main_app
    @app = builder.to_app
  end

  before do
    mock_app
  end

  describe 'with content_security_policy feature flag active' do
    it 'sets the CSP header' do
      FeatureFlag.activate(:content_security_policy)
      get '/foo'

      expect(response.header).to have_key('Content-Security-Policy')
    end
  end

  describe 'with content_security_policy feature flag inactive' do
    it 'does NOT set the CSP header' do
      FeatureFlag.deactivate(:content_security_policy)
      get '/foo'

      expect(response.header).not_to have_key('Content-Security-Policy')
    end
  end
end
