require 'rails_helper'

RSpec.describe EmitRequestEvents, type: :request, with_bigquery: true do
  include DfESignInHelpers

  let(:provider_user) { create(:provider_user, :with_dfe_sign_in) }
  let(:project) { instance_double(Google::Cloud::Bigquery::Project, dataset: dataset) }
  let(:dataset) { instance_double(Google::Cloud::Bigquery::Dataset, table: table) }
  let(:table) { instance_double(Google::Cloud::Bigquery::Table) }

  before do
    FeatureFlag.activate(:send_request_data_to_bigquery)
    allow(Google::Cloud::Bigquery).to receive(:new).and_return(project)
    allow(table).to receive(:insert)

    allow(DfESignInUser).to receive(:load_from_session)
      .and_return(
        DfESignInUser.new(
          email_address: provider_user.email_address,
          dfe_sign_in_uid: provider_user.dfe_sign_in_uid,
          first_name: provider_user.first_name,
          last_name: provider_user.last_name,
        ),
      )
  end

  it 'enqueues request event data with sidekiq worker' do
    Sidekiq::Testing.fake! do
      expect {
        get(provider_interface_applications_path,
            params: { page: '1', per_page: '25', array_param: %w[1 2] },
            headers: { 'HTTP_USER_AGENT' => 'Test agent' })
      }.to change(SendEventsToBigquery.jobs, :size).by(1)

      payload = SendEventsToBigquery.jobs.first['args'].first

      expect(payload['request_method']).to eq('GET')
      expect(payload['request_user_agent']).to eq('Test agent')
      expect(payload['environment']).to eq('test')
      expect(payload['event_type']).to eq('web_request')
      expect(payload['namespace']).to eq('provider_interface')
      expect(payload['response_status']).to eq(200)
      expect(payload['request_query']).to eq([
        { 'key' => 'page', 'value' => ['1'] },
        { 'key' => 'per_page', 'value' => ['25'] },
        { 'key' => 'array_param[]', 'value' => %w[1 2] },
      ])

      schema = File.read('config/event-schema.json')
      schema_validator = JSONSchemaValidator.new(schema, payload)

      expect(schema_validator).to be_valid, schema_validator.failure_message
    end
  end
end
