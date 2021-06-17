require 'rails_helper'

RSpec.describe ProviderInterface::ConfirmConditionsWizard do
  let(:store) { instance_double(WizardStateStores::RedisStore) }
  let(:conditions) { [build_stubbed(:offer_condition, status: :met), build_stubbed(:offer_condition)] }
  let(:offer) { build_stubbed(:offer, conditions: conditions) }
  let(:statuses) { nil }

  let(:wizard) do
    described_class.new(
      store,
      offer: offer,
      statuses: statuses,
    )
  end

  before { allow(store).to receive(:read) }

  describe '#conditions' do
    context 'when built from an offer' do
      it 'returns the conditions of the offer' do
        expect(wizard.conditions).to eq(conditions)
      end
    end

    context 'when built from status params' do
      let(:statuses) do
        conditions.to_h do |condition|
          [condition.id.to_s, { 'status' => %w[pending met unmet].sample }]
        end
      end

      it 'returns the conditions of the offer with modified statuses' do
        modified_conditions = wizard.conditions

        expect(modified_conditions.first.status).to eq(statuses[modified_conditions.first.id.to_s]['status'])
        expect(modified_conditions.last.status).to eq(statuses[modified_conditions.last.id.to_s]['status'])
      end

      context 'if unknown condition ids are given' do
        let(:statuses) do
          {
            'not_an_id' => { 'status' => 'unmet' },
            conditions.last.id.to_s => { 'status' => 'met' },
          }
        end

        it 'only modifies the statuses of the conditions in the offer' do
          modified_conditions = wizard.conditions

          expect(modified_conditions.first.status).to eq(nil)
          expect(modified_conditions.last.status).to eq('met')
        end
      end
    end
  end
end
