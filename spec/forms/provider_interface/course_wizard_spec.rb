require 'rails_helper'
RSpec.describe ProviderInterface::CourseWizard do
  subject(:wizard) do
    described_class.new(store,
                        provider_id: provider_id,
                        course_id: course_id,
                        study_mode: study_mode,
                        application_choice_id: application_choice_id,
                        current_step: current_step)
  end

  let(:store) { instance_double(WizardStateStores::RedisStore) }
  let(:provider_id) { nil }
  let(:course_id) { nil }
  let(:study_mode) { nil }
  let(:application_choice_id) { create(:application_choice).id }
  let(:current_step) { nil }

  before { allow(store).to receive(:read) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:course_id).on(:courses).on(:save) }
  end

  context 'when changing an offer' do
    let(:decision) { :change_offer }
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
  end
end
