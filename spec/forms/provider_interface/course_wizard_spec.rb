require 'rails_helper'
RSpec.describe ProviderInterface::CourseWizard do
  subject(:wizard) do
    described_class.new(store,
                        provider_id:,
                        course_id:,
                        study_mode:,
                        application_choice_id:,
                        current_step:)
  end

  let(:store) { instance_double(WizardStateStores::RedisStore) }
  let(:provider_id) { nil }
  let(:course_id) { nil }
  let(:study_mode) { nil }
  let(:application_choice_id) { create(:application_choice).id }
  let(:current_step) { nil }

  before { allow(store).to receive(:read) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:course_id).on(:courses) }
    it { is_expected.to validate_presence_of(:course_id).on(:save) }
    it { is_expected.to validate_presence_of(:study_mode).on(:study_modes) }
    it { is_expected.to validate_presence_of(:study_mode).on(:save) }
    it { is_expected.to validate_presence_of(:course_option_id).on(:locations) }
    it { is_expected.to validate_presence_of(:course_option_id).on(:save) }
  end

  describe '.build_from_application_choice' do
    let(:application_choice) { create(:application_choice, :awaiting_provider_decision) }
    let(:wizard) do
      described_class.build_from_application_choice(
        store,
        application_choice,
      )
    end

    it 'correctly populates the wizard with application choice attributes' do
      expect(wizard).to be_valid
      expect(wizard.application_choice_id).to eq(application_choice.id)
      expect(wizard.course_id).to eq(application_choice.course_option.course.id)
      expect(wizard.course_option_id).to eq(application_choice.course_option.id)
      expect(wizard.provider_id).to eq(application_choice.course_option.provider.id)
      expect(wizard.study_mode).to eq(application_choice.course_option.study_mode)
      expect(wizard.location_id).to eq(application_choice.course_option.site.id)
    end
  end

  describe '#initialize' do
    context 'is responsible for sanitising the attributes' do
      context 'when the provided course_id does not match the stored value' do
        let(:wizard) do
          described_class.new(store, course_id:)
        end
        let(:stored_data) { { course_id: 5, course_option_id: 3, study_mode: :full_time, provider_id: 10 }.to_json }
        let(:course_id) { 4 }

        before do
          allow(store).to receive(:read).and_return(stored_data)
        end

        it 'resets the study mode and course_option_id' do
          expect(wizard.study_mode).to be_nil
          expect(wizard.course_option_id).to be_nil
          expect(wizard.course_id).to eq(course_id)
          expect(wizard.provider_id).to eq(10)
        end
      end

      context 'when the provided course_id does match the stored value' do
        let(:wizard) do
          described_class.new(store, course_id:)
        end
        let(:stored_data) { { course_id: 5, course_option_id: 3, study_mode: :full_time, provider_id: 10 }.to_json }
        let(:course_id) { 5 }

        before do
          allow(store).to receive(:read).and_return(stored_data)
        end

        it 'does not reset the study mode and course_option_id' do
          expect(wizard.study_mode).to eq('full_time')
          expect(wizard.course_option_id).to eq(3)
          expect(wizard.course_id).to eq(course_id)
          expect(wizard.provider_id).to eq(10)
        end
      end
    end
  end

  context 'when changing a course' do
    let(:query_service) { instance_double(GetChangeOfferOptions) }
    let(:provider_user) { instance_double(ProviderUser) }
    let(:provider_id) { create(:provider).id }
    let(:course_id) { create(:course).id }

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
          allow(query_service).to receive_messages(available_providers: [create(:provider)], available_courses: create_list(:course, 2))
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
          allow(query_service).to receive_messages(available_courses: [create(:course)], available_study_modes: %w[full_time part_time])
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
          allow(query_service).to receive_messages(available_study_modes: %w[part_time], available_course_options: create_list(:course_option, 2))
        end

        it 'returns :locations' do
          expect(wizard.next_step).to eq(:locations)
        end
      end

      context 'when there is only one study mode and location' do
        before do
          allow(query_service).to receive_messages(available_study_modes: %w[part_time], available_course_options: [create(:course_option)])
        end

        it 'returns :check' do
          expect(wizard.next_step).to eq(:check)
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

      context 'when there is only one location available' do
        before do
          allow(query_service).to receive(:available_course_options).and_return([build_stubbed(:course_option)])
        end

        it 'returns :check' do
          expect(wizard.next_step).to eq(:check)
        end
      end
    end

    context 'when the current_step is :locations' do
      let(:current_step) { :locations }

      it 'returns :check' do
        expect(wizard.next_step).to eq(:check)
      end
    end
  end
end
