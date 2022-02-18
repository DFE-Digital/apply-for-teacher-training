require 'rails_helper'
RSpec.describe ProviderInterface::CourseWizard do
  subject(:wizard) do
    described_class.new(store,
                        provider_id: provider_id,
                        application_choice_id: application_choice_id,
                        current_step: current_step)
  end

  let(:store) { instance_double(WizardStateStores::RedisStore) }
  let(:provider_id) { nil }
  let(:application_choice_id) { create(:application_choice).id }
  let(:current_step) { nil }

  describe '#next_step' do
    context 'when changing an offer' do
      let(:decision) { :change_offer }
      let(:query_service) { instance_double(GetChangeOfferOptions) }
      let(:provider_user) { instance_double(ProviderUser) }
      let(:provider_id) { create(:provider).id }

      before do
        allow(ProviderUser).to receive(:find).and_return(provider_user)
        allow(provider_user).to receive(:id).and_return(1)
        allow(GetChangeOfferOptions).to receive(:new).and_return(query_service)
        allow(store).to receive(:write)
        allow(store).to receive(:read)
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
            expect(wizard.next_step).to eq(:courses)
          end
        end
      end
    end
  end
end
