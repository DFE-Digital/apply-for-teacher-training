require 'rails_helper'

# This spec is coupled to the Candidate model. I thought
# this was preferable to making an elaborate mock which
# didn't depend on the db
RSpec.describe EntityEvents do
  let(:interesting_fields) { [] }

  before do
    allow(Rails.configuration).to receive(:analytics).and_return({
      candidates: interesting_fields,
    })
  end

  describe 'entity_created events' do
    context 'when fields are specified in the analytics file' do
      let(:interesting_fields) { [:id] }

      it 'includes attributes specified in the settings file' do
        candidate = create(:candidate)

        expect(SendEventsToBigquery).to have_received(:perform_async)
          .with a_hash_including({
            'event_type' => 'entity_created',
            'data' => [
              { 'key' => 'table_name', 'value' => ['candidates'] },
              { 'key' => 'id', 'value' => [candidate.id] },
            ],
          })
      end

      it 'does not include attributes not specified in the settings file' do
        candidate = create(:candidate, course_from_find_id: 123)

        expect(SendEventsToBigquery).to have_received(:perform_async)
          .with a_hash_including({
            'event_type' => 'entity_created',
            'data' => [
              { 'key' => 'table_name', 'value' => ['candidates'] },
              { 'key' => 'id', 'value' => [candidate.id] },
              # ie the same payload as above
            ],
          })
      end

      it 'sends events that are valid according to the schema' do
        create(:candidate)

        expect(SendEventsToBigquery).to have_received(:perform_async) do |payload|
          schema = File.read('config/event-schema.json')
          schema_validator = JSONSchemaValidator.new(schema, payload)

          expect(schema_validator).to be_valid, schema_validator.failure_message
        end
      end
    end

    context 'when no fields are specified in the analytics file' do
      let(:interesting_fields) { [] }

      it 'does not send entity_created events at all' do
        create(:candidate)
        create(:email) # some other model, for example

        expect(SendEventsToBigquery).not_to have_received(:perform_async)
          .with(a_hash_including({ 'event_type' => 'entity_created' }))
      end
    end
  end
end
