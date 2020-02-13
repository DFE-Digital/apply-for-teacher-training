require 'rails_helper'

RSpec.describe 'GET /integrations/feature-flags', type: :request do
  it 'returns the feature flags' do
    FeatureFlag.activate('pilot_open')

    get '/integrations/feature-flags'

    expect(parsed_response['feature_flags']['pilot_open']['name']).to eql('Pilot open')
    expect(parsed_response['feature_flags']['pilot_open']['active']).to be(true)
  end

  it 'tells us when Sandbox mode is on', sandbox: true do
    get '/integrations/feature-flags'
    expect(parsed_response['feature_flags']['sandbox_mode']['active']).to be(true)
  end

  it 'tells us when Sandbox mode is off', sandbox: false do
    get '/integrations/feature-flags'
    expect(parsed_response['feature_flags']['sandbox_mode']['active']).to be(false)
  end

  def parsed_response
    JSON.parse(response.body)
  end
end
