require 'rails_helper'

RSpec.describe CandidateInterface::StepOperations::PreferencesWizard::AssignDefaultLocationPreferences, type: :model do
  subject(:assign_default_location_preferences) do
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
  let(:current_step) { :training_locations }
  let(:current_step_params) { {} }
  let(:application_choice) do
    create(:application_choice, :awaiting_provider_decision, application_form: current_application)
  end
  let(:site) { application_choice.site }

  describe '#execute' do
    subject(:execute) { assign_default_location_preferences.execute }

    before do
      application_choice
    end

    context 'when the wizard has already been assigned location preferences' do
      let(:location_preference_list) { [{ within: 10, location_name: 'London' }] }

      before do
        state_store.write(location_preference_list:)
      end

      it 'does not assign default location preferences' do
        execute
        expect(wizard.location_preferences).to eq(location_preference_list)
      end
    end

    context 'when the candidate is willing to train anywhere' do
      before do
        state_store.write(training_locations: 'anywhere')
      end

      it 'does not assign default location preferences' do
        execute
        expect(wizard.location_preferences).to eq([])
      end
    end

    context 'when the candidate wants to train in specific locations' do
      before do
        state_store.write(training_locations: 'specific')
        site.update!(latitude: 54.0001, longitude: -2.0003)
      end

      it 'assigns default location preferences' do
        execute

        expect(wizard.location_preferences.map{ |lp| lp.except(:uuid) }).to contain_exactly(
          {
            within: 10,
            location_name: current_application.postcode,
            latitude: current_application.geocode.first,
            longitude: current_application.geocode.last,
          },
          {
            within: 10,
            location_name: site.postcode,
            latitude: 54.0001,
            longitude: -2.0003,
            provider_id: site.provider.id,
          }
        )
        expect(wizard.location_preferences.all?{|lp| lp[:uuid].present?}).to be true
      end
    end
  end
end
