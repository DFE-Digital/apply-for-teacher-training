require 'rails_helper'
RSpec.describe ProviderInterface::OfferWizard do
  subject(:wizard) do
    described_class.new(store,
                        provider_id: provider_id,
                        course_id: course_id,
                        course_option_id: course_option_id,
                        study_mode: study_mode,
                        location_id: location_id,
                        application_choice_id: application_choice_id,
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
  let(:application_choice_id) { create(:application_choice).id }
  let(:standard_conditions) { MakeAnOffer::STANDARD_CONDITIONS }
  let(:further_condition_1) { nil }
  let(:further_condition_2) { nil }
  let(:further_condition_3) { nil }
  let(:further_condition_4) { nil }
  let(:current_step) { nil }
  let(:decision) { nil }

  before { allow(store).to receive(:read) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:decision).on(:select_option) }
    it { is_expected.to validate_presence_of(:course_option_id).on(:locations).on(:save) }
    it { is_expected.to validate_presence_of(:study_mode).on(:study_modes).on(:save) }
    it { is_expected.to validate_presence_of(:course_id).on(:courses).on(:save) }
    it { is_expected.to validate_length_of(:further_condition_1).is_at_most(255) }
    it { is_expected.to validate_length_of(:further_condition_2).is_at_most(255) }
    it { is_expected.to validate_length_of(:further_condition_3).is_at_most(255) }
    it { is_expected.to validate_length_of(:further_condition_4).is_at_most(255) }

    context 'if the course option is in an invalid state' do
      let(:course_option) { create(:course_option) }
      let(:course_option_id) { course_option.id }
      let(:course_id) { course_option.course.id }
      let(:provider_id) { create(:provider).id }
      let(:study_mode) { course_option.study_mode }

      it 'throws an error' do
        expect(wizard.valid?(:save)).to eq(false)
      end
    end
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

        it 'returns :check' do
          expect(wizard.next_step).to eq(:check)
        end
      end
    end

    context 'when changing an offer' do
      let(:decision) { :change_offer }
      let(:query_service) { instance_double(GetChangeOfferOptions) }
      let(:provider_user) { instance_double(ProviderUser) }
      let(:provider_id) { create(:provider).id }
      let(:course_id) { create(:course).id }
      let(:course_option_id) { create(:course_option).id }

      before do
        allow(ProviderUser).to receive(:find).and_return(provider_user)
        allow(provider_user).to receive(:id).and_return(1)
        allow(GetChangeOfferOptions).to receive(:new).and_return(query_service)
        allow(store).to receive(:write)
      end

      context 'when current_step is :select_option' do
        let(:current_step) { :select_option }

        context 'when there are multiple available providers' do
          before do
            allow(query_service).to receive(:available_providers).and_return(create_list(:provider, 2))
          end

          it 'returns :providers' do
            expect(wizard.next_step).to eq(:providers)
          end
        end

        context 'when there is only one available provider' do
          before do
            allow(query_service).to receive(:available_providers).and_return([create(:provider)])
            allow(query_service).to receive(:available_courses).and_return(create_list(:course, 2))
          end

          it 'returns :courses' do
            expect(wizard.next_step).to eq(:courses)
          end
        end
      end

      context 'when current_step is :providers' do
        let(:current_step) { :providers }

        context 'when there are multiple available courses' do
          before do
            allow(query_service).to receive(:available_courses).and_return(create_list(:course, 2))
          end

          it 'returns :courses' do
            expect(wizard.next_step).to eq(:courses)
          end
        end

        context 'when there is only one available course' do
          before do
            allow(query_service).to receive(:available_courses).and_return([create(:course)])
            allow(query_service).to receive(:available_study_modes).and_return(%w[full_time part_time])
          end

          it 'returns :study_modes' do
            expect(wizard.next_step).to eq(:study_modes)
          end
        end
      end

      context 'when current_step is :courses' do
        let(:current_step) { :courses }

        context 'when there are multiple available study modes' do
          before do
            allow(query_service).to receive(:available_study_modes).and_return(%w[full_time part_time])
          end

          it 'returns :study_modes' do
            expect(wizard.next_step).to eq(:study_modes)
          end
        end

        context 'when there is only one study mode' do
          before do
            allow(query_service).to receive(:available_study_modes).and_return(%w[part_time])
            allow(query_service).to receive(:available_course_options).and_return(create_list(:course_option, 2))
          end

          it 'returns :study_modes' do
            expect(wizard.next_step).to eq(:locations)
          end
        end
      end

      context 'when current_step is :study_modes' do
        let(:current_step) { :study_modes }

        context 'when there are multiple locations available' do
          before do
            allow(query_service).to receive(:available_course_options).and_return(create_list(:course_option, 2))
          end

          it 'returns :locations' do
            expect(wizard.next_step).to eq(:locations)
          end
        end

        context 'when there is only one available location' do
          before do
            allow(query_service).to receive(:available_course_options).and_return([create(:course_option)])
          end

          it 'returns :conditions' do
            expect(wizard.next_step).to eq(:conditions)
          end
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

  describe '#previous_step' do
    it { is_expected.to delegate_method(:previous_step).to(:wizard_path_history) }
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

  describe '#configure_additional_conditions' do
    it 'sets further conditions when any defined' do
      wizard.configure_additional_conditions(['Swimming diploma', 'GCSE A Level in Languages'])

      expect(wizard.further_condition_1).to eq('Swimming diploma')
      expect(wizard.further_condition_2).to eq('GCSE A Level in Languages')
    end
  end
end
