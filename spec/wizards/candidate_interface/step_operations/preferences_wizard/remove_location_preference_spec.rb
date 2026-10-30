require 'rails_helper'

RSpec.describe CandidateInterface::StepOperations::PreferencesWizard::RemoveLocationPreference, type: :model do
  subject(:remove_location_preference) do
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
  let(:current_step) { :remove_location_preference }
  let(:current_step_params) { {} }

  describe '#execute' do
    subject(:execute) { remove_location_preference.execute }

    let(:location_preference_list) do
      [
        { uuid: '123abc', location_name: 'London', within: 10 },
        { uuid: '987xyz', location_name: 'Brighton', within: 20 },
      ]
    end

    before do
      state_store.write(uuid: '123abc', location_name: 'London', location_preference_list:)
    end

    it 'removes the location from the location preference list' do
      execute

      expect(wizard.location_preferences).to contain_exactly({ uuid: '987xyz', location_name: 'Brighton', within: 20 })
      expect(state_store.uuid).to be_nil
      expect(state_store.within).to be_nil
      expect(state_store.location_name).to be_nil
    end
  end
end
