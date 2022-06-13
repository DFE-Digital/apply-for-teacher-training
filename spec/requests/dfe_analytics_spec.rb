require 'rails_helper'

RSpec.describe 'dfe_analytics integration' do
  it 'sends request and entity update events' do
    FeatureFlag.activate(:send_request_data_to_bigquery)

    expect {
      post '/candidate/sign-up', params: { candidate_interface_sign_up_form: { email_address: 'email@example.com ' } }
    }.to have_sent_analytics_event_types(:create_entity, :web_request)
  end
end
