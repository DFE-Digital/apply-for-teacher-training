require 'rails_helper'

RSpec.describe 'GET /integrations/feature-flags' do
  it 'returns the feature flags' do
    FeatureFlag.activate('dfe_sign_in_fallback')

    get '/integrations/feature-flags'

    expect(parsed_response['feature_flags']['dfe_sign_in_fallback']['name']).to eql('DfE sign in fallback')
    expect(parsed_response['feature_flags']['dfe_sign_in_fallback']['active']).to be(true)
    expect(parsed_response['feature_flags']['dfe_sign_in_fallback']['type']).to eq('invariant') # deprecated
    expect(parsed_response['feature_flags']['dfe_sign_in_fallback']['variant']).to be(false)
  end

  it 'returns variant feature flags' do
    get '/integrations/feature-flags'

    expect(parsed_response['feature_flags']['send_request_data_to_bigquery']['active']).to be(false)
    expect(parsed_response['feature_flags']['send_request_data_to_bigquery']['type']).to eq('variant') # deprecated
    expect(parsed_response['feature_flags']['send_request_data_to_bigquery']['variant']).to be(true)
  end

  it 'tells us when Sandbox mode is on', :sandbox do
    get '/integrations/feature-flags'
    expect(parsed_response['sandbox_mode']).to be(true)
  end

  it 'tells us when Sandbox mode is off', sandbox: false do
    get '/integrations/feature-flags'
    expect(parsed_response['sandbox_mode']).to be(false)
  end

  def parsed_response
    response.parsed_body
  end
end
