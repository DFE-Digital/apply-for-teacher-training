require 'rails_helper'

RSpec.describe CandidateInterface::StepOperations::PreferencesWizard::SavePreference, type: :model do
  include DfE::Bigquery::TestHelper

  subject(:save_preferences) do
    described_class.new(repository:, step: wizard.current_step)
  end

  before do
    stub_bigquery_non_disclosure_trainee_withdrawals_request
    allow(GoogleMapsAPI::Client).to receive(:new).and_return(client)
    allow(client).to receive(:autocomplete).and_return(api_response)
    state_store.write(current_application_id: current_application.id)
  end

  let(:client) { instance_double(GoogleMapsAPI::Client) }
  let(:api_response) do
    [
      { name: 'BN1 3AA', place_id: },
    ]
  end
  let(:place_id) { 'test_id' }

  let(:repository) do
    DfE::Wizard::Repository::InMemory.new
  end
  let(:state_store) { CandidateInterface::StateStores::PreferencesWizardStore.new(repository:) }
  let(:wizard) do
    CandidateInterface::PreferencesWizard.new(
      current_step:,
      current_step_params:,
      state_store:,
    ).tap do |wizard|
      wizard.current_application = current_application
    end
  end
  let(:current_application) { create(:completed_application_form) }
  let(:current_step) { :publish }
  let(:current_step_params) { {} }

  describe '#execute' do
    subject(:execute) { save_preferences.execute }

    context 'when no preference exists' do
      context 'when the candidate has opted out' do
        before do
          state_store.write(pool_status: 'opt_out', opt_out_reason: 'No thank you.')
        end

        it 'creates an opted out preferences' do
          expect { execute }.to change(CandidatePreference, :count).by(1)
          preference = current_application.published_preference
          expect(preference.pool_status).to eq('opt_out')
          expect(preference.opt_out_reason).to eq('No thank you.')
        end
      end

      context 'when the candidate has opted in, and can train anywhere' do
        before do
          state_store.write(pool_status: 'opt_in', training_locations: 'anywhere')
        end

        it 'creates an opted in preferences' do
          expect { execute }.to change(CandidatePreference, :count).by(1)
          preference = current_application.published_preference
          expect(preference.pool_status).to eq('opt_in')
          expect(preference.training_locations).to eq('anywhere')
        end
      end

      context 'when the candidate has opted in, and can train in specific locations' do
        let(:provider) { create(:provider) }
        let(:location_preference_list) do
          [
            { uuid: '123abc', within: 10, location_name: 'London' },
            { uuid: '123abc', within: 20, location_name: 'Bristol', provider_id: provider.id },
          ]
        end

        before do
          state_store.write(
            pool_status: 'opt_in',
            training_locations: 'specific',
            dynamic_location_preferences: true,
            funding_type: 'fee',
            location_preference_list:,
          )
        end

        it 'creates an opted in preferences' do
          expect { execute }.to change(CandidatePreference, :count).by(1).and change(CandidateLocationPreference, :count).by(2)
          preference = current_application.published_preference
          expect(preference.pool_status).to eq('opt_in')
          expect(preference.training_locations).to eq('specific')
          location_preferences = preference.location_preferences.order(:name)

          bristol_location_preference = location_preferences.first
          expect(bristol_location_preference.name).to eq('Bristol')
          expect(bristol_location_preference.within).to eq(20.0)
          expect(bristol_location_preference.latitude.to_s).to eq('53.4706519')
          expect(bristol_location_preference.longitude.to_s).to eq('-2.2954452')
          expect(bristol_location_preference.provider_id).to eq(provider.id)

          london_location_preference = location_preferences.last
          expect(london_location_preference.name).to eq('London')
          expect(london_location_preference.within).to eq(10.0)
          expect(london_location_preference.latitude.to_s).to eq('53.4706519')
          expect(london_location_preference.longitude.to_s).to eq('-2.2954452')
          expect(london_location_preference.provider_id).to be_nil
        end
      end
    end

    context 'when a preferences exists' do
      before { preference }

      context 'when the candidate has opted out' do
        let(:preference) { create(:candidate_preference, application_form: current_application) }

        before do
          state_store.write(pool_status: 'opt_out', opt_out_reason: 'No thank you.')
        end

        it 'creates an opted out preferences' do
          expect { execute }.not_to change(CandidatePreference, :count)
          preference.reload
          expect(preference.pool_status).to eq('opt_out')
          expect(preference.opt_out_reason).to eq('No thank you.')
        end
      end

      context 'when the candidate has opted in, and can train anywhere' do
        let(:preference) { create(:candidate_preference, :opt_out, application_form: current_application) }

        before do
          state_store.write(pool_status: 'opt_in', training_locations: 'anywhere')
        end

        it 'creates an opted in preferences' do
          expect { execute }.not_to change(CandidatePreference, :count)
          preference.reload
          expect(preference.pool_status).to eq('opt_in')
          expect(preference.training_locations).to eq('anywhere')
        end
      end

      context 'when the candidate has opted in, and can train in specific locations' do
        let(:preference) { create(:candidate_preference, :opt_out, application_form: current_application) }
        let(:provider) { create(:provider) }
        let(:location_preference_list) do
          [
            { uuid: '123abc', within: 10, location_name: 'London' },
            { uuid: '123abc', within: 20, location_name: 'Bristol', provider_id: provider.id },
          ]
        end

        before do
          state_store.write(
            pool_status: 'opt_in',
            training_locations: 'specific',
            dynamic_location_preferences: true,
            funding_type: 'fee',
            location_preference_list:,
          )
        end

        it 'creates an opted in preferences' do
          expect { execute }.to change(CandidateLocationPreference, :count).by(2)
          preference.reload
          expect(preference.pool_status).to eq('opt_in')
          expect(preference.training_locations).to eq('specific')
          location_preferences = preference.location_preferences.order(:name)

          bristol_location_preference = location_preferences.first
          expect(bristol_location_preference.name).to eq('Bristol')
          expect(bristol_location_preference.within).to eq(20.0)
          expect(bristol_location_preference.latitude.to_s).to eq('53.4706519')
          expect(bristol_location_preference.longitude.to_s).to eq('-2.2954452')
          expect(bristol_location_preference.provider_id).to eq(provider.id)

          london_location_preference = location_preferences.last
          expect(london_location_preference.name).to eq('London')
          expect(london_location_preference.within).to eq(10.0)
          expect(london_location_preference.latitude.to_s).to eq('53.4706519')
          expect(london_location_preference.longitude.to_s).to eq('-2.2954452')
          expect(london_location_preference.provider_id).to be_nil
        end
      end
    end
  end
end
