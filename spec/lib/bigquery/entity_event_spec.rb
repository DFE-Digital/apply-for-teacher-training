require 'rails_helper'

RSpec.describe Bigquery::EntityEvent do
  let(:candidate) { create(:candidate) }
  let(:pii_fields) { [] }
  let(:interesting_fields) { [] }
  let(:event_type) { 'create_entity' }
  let(:event) { described_class.new(candidate, event_type).to_event }
  let(:parsed_event) { JSON.parse(event.to_json) }

  before do
    allow(Rails.configuration).to receive(:analytics).and_return({
      candidates: interesting_fields,
    })

    allow(Rails.configuration).to receive(:analytics_pii).and_return({
      candidates: pii_fields,
    })
  end

  it 'defaults the event type to import_entity' do
    expect(parsed_event['event_type']).to eq(event_type)
  end

  context 'when fields are specified in the analytics file' do
    let(:interesting_fields) { [:id] }

    it 'only includes attributes specified in the settings file' do
      expect(parsed_event['entity_table_name']).to eq('candidates')
      expect(parsed_event['data']).to eq([{ 'key' => 'id', 'value' => [candidate.id] }])
    end
  end

  context 'the specified fields are listed as PII' do
    let(:interesting_fields) { [:email_address] }
    let(:pii_fields) { [:email_address] }
    let(:candidate) { create(:candidate, email_address: 'adrienne@example.com') }

    it 'hashes those fields' do
      expect(parsed_event['data']).to eq([{ 'key' => 'email_address',
                                            'value' => ['928b126cb77de8a61bf6714b4f6b0147be7f9d5eb60158930c34ef70f4d502d6'] }])
    end
  end
end
