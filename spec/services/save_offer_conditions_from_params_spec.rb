require 'rails_helper'

RSpec.describe SaveOfferConditionsFromParams do
  subject(:service) do
    described_class.new(application_choice: application_choice,
                        standard_conditions: standard_conditions,
                        further_condition_attrs: further_condition_attrs)
  end

  let(:standard_conditions) { [] }
  let(:further_condition_attrs) { {} }
  let(:application_choice) { build(:application_choice) }

  describe '#conditions' do
    let(:standard_conditions) { [OfferCondition::STANDARD_CONDITIONS.sample] }
    let(:further_condition_attrs) do
      {
        0 => {
          'text' => 'You must have a driving license',
        },
        1 => {
          'text' => 'Blue hair',
        },
      }
    end

    it 'returns a text array of all serialized conditions' do
      expect(service.conditions).to contain_exactly(standard_conditions.first, 'You must have a driving license', 'Blue hair')
    end
  end

  describe '#save' do
    context 'when there is no offer for the application_choice' do
      it 'create an offer when one does not exist' do
        expect { service.save }.to change(Offer, :count).by(1)
      end
    end

    context 'when there is an existing offer for the application_choice' do
      let!(:application_choice) { create(:application_choice, :with_offer) }

      it 'create an offer when one does not exist' do
        expect { service.save }.to change(Offer, :count).by(0)
      end
    end

    context 'when there is an existing offer with non-pending conditions' do
      let!(:application_choice) { create(:application_choice, :with_offer, offer: offer) }
      let(:offer) do
        build(:offer, conditions: [build(:offer_condition, text: OfferCondition::STANDARD_CONDITIONS.first, status: :met),
                                   build(:offer_condition, text: 'Red hair')])
      end

      it 'raises a validation error' do
        expect { service.save }.to raise_error(ValidationException)
                                     .and change(offer.conditions, :count).by(0)
      end
    end

    context 'when we have standard and further conditions' do
      context 'when we make changes to further conditions' do
        let!(:application_choice) { create(:application_choice, :with_offer, offer: offer) }
        let(:offer) do
          build(:offer, conditions: [build(:offer_condition, text: OfferCondition::STANDARD_CONDITIONS.first),
                                     build(:offer_condition, text: OfferCondition::STANDARD_CONDITIONS.last),
                                     build(:offer_condition, text: 'Red hair')])
        end

        let(:standard_conditions) { [OfferCondition::STANDARD_CONDITIONS.sample] }
        let(:further_condition_attrs) do
          {
            0 => {
              'text' => 'You must have a driving license',
            },
            1 => {
              'condition_id' => offer.conditions.last.id,
              'text' => 'Blue hair',
            },
          }
        end

        it 'returns the expected results' do
          service.save

          expect(offer.reload.conditions.map(&:text)).to contain_exactly(standard_conditions.first,
                                                                         'You must have a driving license',
                                                                         'Blue hair')
        end
      end
    end

    context 'standard_conditions' do
      let!(:application_choice) { create(:application_choice, :with_offer, offer: offer) }
      let(:standard_conditions) { [OfferCondition::STANDARD_CONDITIONS.sample] }

      context 'when they dont already exist on the offer' do
        let(:offer) { build(:unconditional_offer) }

        it 'the service creates them' do
          expect { service.save }.to change(offer.conditions, :count).by(1)
        end
      end

      context 'when they do exist on the offer' do
        let(:offer) { build(:offer, conditions: [build(:offer_condition, text: standard_conditions.first)]) }

        it 'the service does nothing' do
          expect { service.save }.to change(offer.conditions, :count).by(0)
        end
      end

      context 'when they are removed' do
        let(:offer) { build(:offer, conditions: [build(:offer_condition, text: OfferCondition::STANDARD_CONDITIONS.first)]) }
        let(:standard_conditions) { [] }

        it 'the service deletes the existing entries' do
          expect { service.save }.to change(offer.conditions, :count).by(-1)
        end
      end
    end

    context 'further_conditions' do
      let!(:application_choice) { create(:application_choice, :with_offer, offer: offer) }
      let(:further_condition_attrs) do
        {
          0 => {
            'text' => 'You must have a driving license',
          },
        }
      end

      context 'when they dont already exist on the offer' do
        let(:offer) { build(:unconditional_offer) }

        it 'the service creates them' do
          expect { service.save }.to change(offer.conditions, :count).by(1)
          expect(offer.conditions.first.text).to eq('You must have a driving license')
        end
      end

      context 'when they do exist on the offer' do
        let(:offer) { build(:offer, conditions: [build(:offer_condition, text: 'You must have a driving license')]) }
        let(:further_condition_attrs) do
          {
            0 => {
              'condition_id' => offer.conditions.first.id,
              'text' => 'You must have a driving license',
            },
          }
        end

        it 'the service does nothing' do
          expect { service.save }.to change(offer.conditions, :count).by(0)
        end
      end

      context 'when they are removed' do
        let(:offer) { build(:offer, conditions: [build(:offer_condition, text: 'You must have a driving license')]) }
        let(:further_condition_attrs) { {} }

        it 'the service deletes the existing entries' do
          expect { service.save }.to change(offer.conditions, :count).by(-1)
        end
      end

      context 'when they are updated' do
        let!(:application_choice) { create(:application_choice, :with_offer, offer: offer) }
        let(:offer) { build(:offer, conditions: [build(:offer_condition, text: 'You must have a driving license')]) }
        let(:further_condition_attrs) do
          {
            0 => {
              'condition_id' => offer.conditions.first.id,
              'text' => 'You must NOT have a driving license',
            },
          }
        end

        it 'the service updates the existing entries' do
          expect { service.save }
            .to change(offer.conditions, :count).by(0)
            .and change { offer.conditions.first.reload.text }.to('You must NOT have a driving license')
        end
      end

      context 'when a conditions with an invalid id is provided' do
        let!(:application_choice) { create(:application_choice, :with_offer, offer: offer) }
        let(:offer) { build(:unconditional_offer) }
        let(:further_condition_attrs) do
          {
            0 => {
              'conditions_id' => '',
              'text' => 'A valid new condition',
            },
            1 => {
              'condition_id' => 999,
              'text' => 'You must NOT have a driving license',
            },
          }
        end

        it 'the entire transaction is cancelled' do
          expect { service.save }.to raise_error(ValidationException)
            .and change(offer.conditions, :count).by(0)
        end
      end
    end
  end
end
