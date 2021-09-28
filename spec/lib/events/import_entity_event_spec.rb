require 'rails_helper'

RSpec.describe Events::ImportEntityEvent do
  let(:candidate) { create(:candidate) }
  let(:pii_fields) { [] }
  let(:interesting_fields) { [] }

  before do
    allow(Rails.configuration).to receive(:analytics).and_return({
      candidates: interesting_fields,
    })

    allow(Rails.configuration).to receive(:analytics_pii).and_return({
      candidates: pii_fields,
    })
  end

  it 'defaults the event type to import_entity' do
    event = described_class.new(candidate)

    expect(event.event_type).to eq('import_entity')
  end

  context 'when fields are specified in the analytics file' do
    let(:interesting_fields) { [:id] }

    it 'only includes attributes specified in the settings file' do
      described_class.new(candidate).send

      expect(SendEventsToBigquery).to have_received(:perform_async)
        .with a_hash_including({
          'entity_table_name' => 'candidates',
          'event_type' => 'import_entity',
          'data' => [
            { 'key' => 'id', 'value' => [candidate.id] },
          ],
        })
    end

    it 'sends events that are valid according to the schema' do
      described_class.new(candidate).send

      expect(SendEventsToBigquery).to have_received(:perform_async) do |payload|
        schema = File.read('config/event-schema.json')
        schema_validator = JSONSchemaValidator.new(schema, payload)

        expect(schema_validator).to be_valid, schema_validator.failure_message
      end
    end
  end

  context 'the specified fields are listed as PII' do
    let(:interesting_fields) { [:email_address] }
    let(:pii_fields) { [:email_address] }
    let(:candidate) { create(:candidate, email_address: 'adrienne@example.com') }

    it 'hashes those fields' do
      described_class.new(candidate).send

      expect(SendEventsToBigquery).to have_received(:perform_async)
        .with a_hash_including({
          'data' => [
            { 'key' => 'email_address', 'value' => ['928b126cb77de8a61bf6714b4f6b0147be7f9d5eb60158930c34ef70f4d502d6'] },
          ],
        })
    end
  end
end
