require 'rails_helper'

RSpec.describe CandidateInterface::Steps::CourseSelectionWizard::CourseStudyMode, type: :model do
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
    end
  end
  let(:current_application) { create(:completed_application_form) }
  let(:current_step) { :course_study_mode }
  let(:current_step_params) { {} }

  describe '#delegations' do
    subject(:step) { described_class.new(wizard:) }

    it { is_expected.to delegate_method(:provider).to(:wizard) }
    it { is_expected.to delegate_method(:provider_exists?).to(:wizard) }
    it { is_expected.to delegate_method(:multiple_sites?).to(:wizard) }
  end

  describe 'attributes' do
    it 'has attributes associated with the form' do
      expect(described_class.new).to have_attributes(study_mode: nil)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:study_mode) }
  end

  describe '#permitted_params' do
    it 'returns the permitted_params' do
      expect(described_class.permitted_params).to contain_exactly(:study_mode)
    end
  end

  describe '.completed?' do
    context 'when the course has multiple sites' do
      before { allow(wizard).to receive(:multiple_sites?).and_return(true) }

      it 'returns false' do
        expect(described_class.new(wizard:).completed?).to be(false)
      end
    end

    context 'when the course does not have multiple sites' do
      before { allow(wizard).to receive(:multiple_sites?).and_return(false) }

      it 'returns true' do
        expect(described_class.new(wizard:).completed?).to be(true)
      end
    end
  end
end
