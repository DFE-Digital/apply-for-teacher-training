require 'rails_helper'

describe MakeAnOffer do
  context 'when a conditional offer is make successfully' do
    let(:application_choice) { create(:application_choice, provider_ucas_code: 'ABC') }
    let(:response) { MakeAnOffer.new(application_choice: application_choice, offer_conditions: conditions).call }
    let(:conditions) do
      {
        "conditions": [
          'Completion of subject knowledge enhancement',
          'Completion of professional skills test',
        ],
      }
    end

    it 'returns a success' do
      expect(response.successful?).to be true
    end

    it 'returns the updated application choice' do
      expect(response.application_choice.status).to eq('conditional_offer')
      expect(response.application_choice.offer).to eq(
        'conditions' => [
          'Completion of subject knowledge enhancement',
          'Completion of professional skills test',
        ],
      )
    end
  end


  context 'when an unconditional offer is make successfully' do
    let(:application_choice) { create(:application_choice, provider_ucas_code: 'ABC') }
    let(:make_an_offer) { MakeAnOffer.new(application_choice: application_choice, offer_conditions: nil) }

    it 'returns a success' do
      response = make_an_offer.call

      expect(response.successful?).to be true
    end

    it 'returns the updated application choice' do
      response = make_an_offer.call

      expect(response.application_choice.status).to eq('unconditional_offer')
      expect(response.application_choice.offer).to eq(
        'conditions' => [],
      )
    end
  end
end
