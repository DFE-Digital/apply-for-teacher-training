require 'rails_helper'

RSpec.describe CandidateInterface::StepOperations::PreferencesWizard::AssignLocationPreference, type: :model do
  subject(:assign_location_preference) do
    described_class.new(repository:, step: wizard.current_step)
  end

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
  let(:current_step) { :add_location_preference }
  let(:current_step_params) { {} }

  describe '#execute' do
    subject(:execute) { assign_location_preference.execute }

    context 'when no location preferences have been set' do
      before do
        state_store.write(uuid: '123abc', within: 15, location_name: 'London')
      end

      it 'assigns the location to the location preference list' do
        execute

        expect(wizard.location_preferences).to contain_exactly({ uuid: '123abc', within: 15, location_name: 'London' })
        expect(state_store.uuid).to be_nil
        expect(state_store.within).to be_nil
        expect(state_store.location_name).to be_nil
      end
    end

    context 'when location preferences have been set' do
      let(:location_preference_list) { [existing_location_preference] }
      let(:existing_location_preference) do
        { uuid: '987xyz', within: 20, location_name: 'Brighton' }
      end

      before do
        state_store.write(uuid: '123abc', within: 15, location_name: 'London', location_preference_list:)
      end

      it 'assigns the location to the location preference list' do
        execute

        expect(wizard.location_preferences).to contain_exactly(existing_location_preference, { uuid: '123abc', within: 15, location_name: 'London' })
        expect(state_store.uuid).to be_nil
        expect(state_store.within).to be_nil
        expect(state_store.location_name).to be_nil
      end
    end
  end
end
