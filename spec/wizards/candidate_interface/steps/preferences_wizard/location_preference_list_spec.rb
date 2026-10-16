require 'rails_helper'

RSpec.describe CandidateInterface::Steps::PreferencesWizard::LocationPreferenceList, type: :model do
  subject(:step) { wizard.current_step }

  let(:location_preferences) { [] }

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
  let(:current_step) { :location_preference_list }
  let(:current_step_params) { {} }
  let(:location_preference_list) { [] }

  before do
    state_store.write(location_preference_list:, current_application_id: current_application.id)
  end

  describe 'validations' do
    context 'when no location preferences have been set' do
      it 'is invalid' do
        expect(step).not_to be_valid
        expect(step.errors.full_messages).to eq(
          ['Add an area you can train in'],
        )
      end
    end

    context 'when location preferences have been set' do
      let(:location_preference_list) { [{ within: 10, uid: 'abc123', location_name: 'London' }] }

      it 'is valid' do
        expect(step).to be_valid
      end
    end
  end
end
