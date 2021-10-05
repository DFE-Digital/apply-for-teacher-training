require 'rails_helper'

RSpec.describe Bigquery::ImportEntityEvents do
  let(:candidates) { create_list(:candidate, 1) }

  before do
    allow(Rails.configuration).to receive(:analytics).and_return({
      candidates: [],
    })

    allow(Rails.configuration).to receive(:analytics_pii).and_return({
      candidates: [],
    })
  end

  it 'converts and sends events that are valid according to the schema' do
    described_class.new(candidates).call

    expect(SendEventsToBigquery).to have_received(:perform_async) do |payload|
      schema = File.read('config/event-schema.json')
      schema_validator = JSONSchemaValidator.new(schema, payload.first)

      expect(schema_validator).to be_valid, schema_validator.failure_message
    end
  end
end
