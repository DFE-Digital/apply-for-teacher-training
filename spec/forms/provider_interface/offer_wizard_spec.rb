require 'rails_helper'
RSpec.describe ProviderInterface::OfferWizard do
  let(:store) { instance_double(WizardStateStores::RedisStore) }

  let(:wizard) do
    described_class.new(store,
                        provider_id: provider_id,
                        course_id: course_id,
                        course_option_id: course_option_id,
                        study_mode: study_mode,
                        location_id: location_id,
                        standard_conditions: standard_conditions,
                        further_condition_1: further_condition_1,
                        further_condition_2: further_condition_2,
                        further_condition_3: further_condition_3,
                        further_condition_4: further_condition_4,
                        current_step: current_step,
                        current_context: current_context)
  end

  let(:provider_id) { nil }
  let(:course_id) { nil }
  let(:course_option_id) { nil }
  let(:study_mode) { nil }
  let(:location_id) { nil }
  let(:standard_conditions) { MakeAnOffer::STANDARD_CONDITIONS }
  let(:further_condition_1) { nil }
  let(:further_condition_2) { nil }
  let(:further_condition_3) { nil }
  let(:further_condition_4) { nil }
  let(:current_step) { nil }
  let(:current_context) { nil }

  before { allow(store).to receive(:read) }

  describe '#next_step' do
    context 'make offer context' do
      let(:current_context) { :make_offer }

      context 'when current_step is :select_option' do
        let(:current_step) { :select_option }

        it 'returns :conditions' do
          expect(wizard.next_step).to eq(:conditions)
        end
      end

      context 'when current_step is :conditions' do
        let(:current_step) { :conditions }

        it 'returns :conditions' do
          expect(wizard.next_step).to eq(:check)
        end
      end

      context 'when the current step does not exist' do
        let(:current_step) { :not_existing }

        it 'returns :select_option' do
          expect(wizard.next_step).to eq(:select_option)
        end
      end
    end
  end

  describe '#conditions' do
    let(:standard_conditions) { ['', MakeAnOffer::STANDARD_CONDITIONS.last] }
    let(:further_condition_3) { 'They must graduate from their current course with an Honors' }
    let(:further_condition_1) { 'Receiving an A* on their Maths A Level' }

    it 'constructs an array with the offer conditions' do
      expect(wizard.conditions).to eq([MakeAnOffer::STANDARD_CONDITIONS.last,
                                       further_condition_1,
                                       further_condition_3])
    end
  end
end
