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
    it { is_expected.to validate_presence_of(:decision).on(:select_option) }
    it { is_expected.to validate_presence_of(:course_option_id).on(:locations).on(:save) }
    it { is_expected.to validate_presence_of(:study_mode).on(:study_modes).on(:save) }
    it { is_expected.to validate_presence_of(:course_id).on(:courses).on(:save) }
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

        it 'returns :check' do
          expect(wizard.next_step).to eq(:check)
        end
      end
    end

    context 'when changing an offer' do
      let(:decision) { :change_offer }

      context 'when current_step is :select_option' do
        let(:current_step) { :select_option }

        context 'when there are multiple available providers' do
          before do
            provider_user = instance_double(ProviderUser, providers: build_stubbed_list(:provider, 2))
            allow(ProviderUser).to receive(:find).and_return(provider_user)
          end

          it 'returns :providers' do
            expect(wizard.next_step).to eq(:providers)
          end
        end

        context 'when there is only one available provider' do
          before do
            courses = build_stubbed_list(:course, 2)
            provider = instance_double(Provider, id: :stub_id, courses: courses)
            provider_user = instance_double(ProviderUser, providers: [provider])
            allow(ProviderUser).to receive(:find).and_return(provider_user)
            allow(store).to receive(:write)
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
            allow(Course).to receive(:where).and_return(class_double(Course, one?: false))
          end

          it 'returns :courses' do
            expect(wizard.next_step).to eq(:courses)
          end
        end

        context 'when there is only one available course' do
          before do
            course = instance_double(Course, id: :stub_id)

            allow(course).to receive(:available_study_modes_from_options).and_return(%i[full_time part_time])
            allow(Course).to receive(:where).and_return([course])
            allow(Course).to receive(:find).and_return(course)
            allow(store).to receive(:write)
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
            course = instance_double(Course)
            allow(course).to receive(:available_study_modes_from_options).and_return(%i[full_time part_time])
            allow(Course).to receive(:find).and_return(course)
          end

          it 'returns :study_modes' do
            expect(wizard.next_step).to eq(:study_modes)
          end
        end

        context 'when there is only one study mode' do
          before do
            course = instance_double(Course)
            course_option = class_double(CourseOption, one?: false)

            allow(course).to receive(:available_study_modes_from_options).and_return([:full_time])
            allow(Course).to receive(:find).and_return(course)
            allow(CourseOption).to receive(:where).and_return(course_option)
            allow(store).to receive(:write)
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
            course_option = class_double(CourseOption, one?: false)

            allow(CourseOption).to receive(:where).and_return(course_option)
          end

          it 'returns :locations' do
            expect(wizard.next_step).to eq(:locations)
          end
        end

        context 'when there is only one available location' do
          before do
            course_option = instance_double(CourseOption, id: :stub_id)

            allow(CourseOption).to receive(:where).and_return([course_option])
            allow(store).to receive(:write)
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
    before do
      wizard.path_history = %i[provider courses locations]
      wizard.current_step = :locations
    end

    it 'returns the step before the current_step' do
      expect(wizard.previous_step).to eq(:courses)
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
