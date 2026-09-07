require 'rails_helper'

RSpec.describe CandidateInterface::StepOperations::CourseSelectionWizard::UpdateApplicationChoiceVisa, type: :model do
  subject(:update_application_choice_visa) do
    described_class.new(repository:, step: wizard.current_step)
  end

  let(:repository) do
    DfE::Wizard::Repository::InMemory.new
  end
  let(:state_store) { CandidateInterface::StateStores::CourseSelectionWizardStore.new(repository:) }
  let(:wizard) do
    CandidateInterface::CourseSelectionWizard.new(
      current_step:,
      current_step_params:,
      state_store:,
    ).tap do |wizard|
      wizard.current_application = current_application
      wizard.application_choice = application_choice
    end
  end
  let(:current_application) { create(:completed_application_form) }
  let(:application_choice) { create(:application_choice, application_form: current_application) }
  let(:current_step) { :visa_explanation }
  let(:current_step_params) { {} }

  describe 'delegation' do
    it { is_expected.to delegate_method(:application_choice).to(:wizard) }
    it { is_expected.to delegate_method(:state_store).to(:wizard) }

    it { is_expected.to delegate_method(:visa_explanation).to(:state_store) }
    it { is_expected.to delegate_method(:visa_explanation_details).to(:state_store) }
  end

  describe '.execute' do
    before do
      state_store.write(visa_explanation: 'other', visa_explanation_details: 'I will renew my visa')
    end

    it 'updates the visa explanation details of the application choice' do
      update_application_choice_visa.execute
      application_choice.reload
      expect(application_choice.visa_explanation).to eq('other')
      expect(application_choice.visa_explanation_details).to eq('I will renew my visa')
    end
  end
end
