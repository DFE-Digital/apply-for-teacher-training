require 'rails_helper'
RSpec.describe ProviderInterface::OfferWizard do
  subject(:wizard) do
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
                        decision: decision)
  end

  let(:store) { instance_double(WizardStateStores::RedisStore) }
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
  let(:decision) { nil }

  before { allow(store).to receive(:read) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:decision) }
    it { is_expected.to validate_presence_of(:course_option_id).on(:locations) }
    it { is_expected.to validate_presence_of(:study_mode).on(:study_modes) }
    it { is_expected.to validate_presence_of(:course_id).on(:courses) }
    it { is_expected.to validate_length_of(:further_condition_1).is_at_most(255) }
    it { is_expected.to validate_length_of(:further_condition_2).is_at_most(255) }
    it { is_expected.to validate_length_of(:further_condition_3).is_at_most(255) }
    it { is_expected.to validate_length_of(:further_condition_4).is_at_most(255) }
  end

  describe '#next_step' do
    context 'when making an offer' do
      let(:decision) { :make_offer }

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
    end

    context 'when changing an offer' do
      let(:decision) { :change_offer }

      context 'when current_step is :select_option' do
        let(:current_step) { :select_option }

        it 'returns :providers' do
          expect(wizard.next_step).to eq(:providers)
        end
      end

      context 'when current_step is :providers' do
        let(:current_step) { :providers }

        it 'returns :courses' do
          expect(wizard.next_step).to eq(:courses)
        end
      end

      context 'when current_step is :courses' do
        let(:current_step) { :courses }

        it 'returns :study_modes' do
          expect(wizard.next_step).to eq(:study_modes)
        end
      end

      context 'when current_step is :study_modes' do
        let(:current_step) { :study_modes }

        it 'returns :locations' do
          expect(wizard.next_step).to eq(:locations)
        end
      end

      context 'when current_step is :locations' do
        let(:current_step) { :locations }

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
